package com.vrp.servlet;

import com.vrp.dao.ChatDAO;
import com.vrp.model.ChatMessage;
import com.vrp.model.User;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

/**
 * Handles the live chat feature.
 *
 * GET  admin       — admin conversation list page
 * GET  history     — JSON array of all messages for a conversation (used by widget)
 * GET  poll        — JSON array of messages since `since` timestamp
 * GET  unread      — JSON unread count for current user
 * POST send        — send a message (returns JSON)
 */
@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    private ChatDAO chatDAO;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String base = System.getProperty("user.home") + "/vrp_data/";
        chatDAO = new ChatDAO(base + "messages.txt");
    }

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "";

        User user = sessionUser(req);

        // JSON endpoints — return early if not authenticated
        if ("poll".equals(action) || "history".equals(action) || "unread".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            if (user == null) { resp.getWriter().write("{\"error\":\"unauthorized\"}"); return; }
        }

        try {
            switch (action) {

                // ── Admin page: list all conversations ────────────────────────
                case "admin": {
                    if (user == null) { resp.sendRedirect(req.getContextPath() + "/auth?action=login"); return; }
                    if (!user.isAdmin()) { resp.sendRedirect(req.getContextPath() + "/auth?action=dashboard"); return; }
                    List<Map<String, Object>> convs = chatDAO.getConversationList();
                    long totalUnread = chatDAO.getTotalAdminUnread();
                    req.setAttribute("conversations",  convs);
                    req.setAttribute("totalUnread",    totalUnread);
                    req.setAttribute("pageTitle",      "Live Chat — DriveLanka Admin");
                    req.setAttribute("nav",            "chat");
                    req.getRequestDispatcher("/WEB-INF/views/adminChat.jsp").forward(req, resp);
                    return;
                }

                // ── Conversation list as JSON (admin, for live polling) ───────
                case "conversations": {
                    resp.setContentType("application/json;charset=UTF-8");
                    if (user == null || !user.isAdmin()) { resp.getWriter().write("[]"); return; }
                    try {
                        List<Map<String, Object>> convs = chatDAO.getConversationList();
                        StringBuilder sb = new StringBuilder("[");
                        for (int i = 0; i < convs.size(); i++) {
                            if (i > 0) sb.append(",");
                            Map<String, Object> cv = convs.get(i);
                            String cid  = (String) cv.get("conversationId");
                            ChatMessage lm = (ChatMessage) cv.get("lastMessage");
                            long unread = (Long) cv.get("unreadCount");
                            int  cnt    = (Integer) cv.get("messageCount");
                            String rawContent = lm.getContent() == null ? "" : lm.getContent();
                            String preview = rawContent.length() > 60
                                ? rawContent.substring(0, 60) + "…" : rawContent;
                            sb.append(String.format(
                                "{\"id\":\"%s\",\"preview\":\"%s\",\"time\":\"%s\"," +
                                "\"unread\":%d,\"count\":%d,\"fromAdmin\":%b}",
                                esc(cid), esc(preview), esc(lm.getShortTime()),
                                unread, cnt, lm.isFromAdmin()));
                        }
                        sb.append("]");
                        resp.getWriter().write(sb.toString());
                    } catch (Exception ex) {
                        resp.getWriter().write("[]");
                    }
                    return;
                }

                // ── Full history for a conversation (JSON) ────────────────────
                case "history": {
                    String convId = user.isAdmin() ? req.getParameter("with") : user.getUsername();
                    if (convId == null) { resp.getWriter().write("[]"); return; }
                    List<ChatMessage> msgs = chatDAO.getConversation(convId);
                    chatDAO.markRead(convId, user.isAdmin() ? "ADMIN" : "CUSTOMER");
                    writeMessagesJson(resp.getWriter(), msgs);
                    return;
                }

                // ── Incremental poll (JSON) ───────────────────────────────────
                case "poll": {
                    String convId = user.isAdmin() ? req.getParameter("with") : user.getUsername();
                    String since  = req.getParameter("since");
                    if (convId == null || since == null) { resp.getWriter().write("[]"); return; }
                    List<ChatMessage> msgs = chatDAO.getMessagesSince(convId, since);
                    chatDAO.markRead(convId, user.isAdmin() ? "ADMIN" : "CUSTOMER");
                    writeMessagesJson(resp.getWriter(), msgs);
                    return;
                }

                // ── Unread count (JSON) ───────────────────────────────────────
                case "unread": {
                    long count = user.isAdmin()
                        ? chatDAO.getTotalAdminUnread()
                        : chatDAO.getUnreadCountForCustomer(user.getUsername());
                    resp.getWriter().write("{\"count\":" + count + "}");
                    return;
                }

                default:
                    if (user != null && user.isAdmin())
                        resp.sendRedirect(req.getContextPath() + "/chat?action=admin");
                    else
                        resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            }
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    // ── POST (send message) ───────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = sessionUser(req);
        if (user == null) { resp.getWriter().write("{\"error\":\"unauthorized\"}"); return; }

        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty()) {
            resp.getWriter().write("{\"error\":\"empty\"}"); return;
        }
        content = content.trim();
        if (content.length() > 2000) content = content.substring(0, 2000);

        try {
            String convId = user.isAdmin() ? req.getParameter("with") : user.getUsername();
            if (convId == null || convId.trim().isEmpty()) {
                resp.getWriter().write("{\"error\":\"no_conversation\"}"); return;
            }

            String messageId = chatDAO.nextMessageId();
            String timestamp = ChatMessage.nowTimestamp();
            ChatMessage msg  = new ChatMessage(
                messageId, convId, user.getUsername(),
                user.isAdmin() ? "ADMIN" : "CUSTOMER",
                content, timestamp, false
            );
            chatDAO.addMessage(msg);

            resp.getWriter().write(String.format(
                "{\"success\":true,\"messageId\":\"%s\",\"timestamp\":\"%s\",\"shortTime\":\"%s\"}",
                esc(messageId), esc(timestamp), esc(msg.getShortTime())
            ));
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────
    private void writeMessagesJson(PrintWriter out, List<ChatMessage> msgs) {
        out.write("[");
        for (int i = 0; i < msgs.size(); i++) {
            if (i > 0) out.write(",");
            ChatMessage m = msgs.get(i);
            out.write(String.format(
                "{\"id\":\"%s\",\"from\":\"%s\",\"role\":\"%s\"," +
                "\"content\":\"%s\",\"timestamp\":\"%s\",\"shortTime\":\"%s\"}",
                esc(m.getMessageId()), esc(m.getFromUsername()), esc(m.getFromRole()),
                esc(m.getContent()), esc(m.getTimestamp()), esc(m.getShortTime())
            ));
        }
        out.write("]");
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private User sessionUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute("loggedInUser");
    }
}
