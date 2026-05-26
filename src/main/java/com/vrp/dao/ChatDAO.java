package com.vrp.dao;

import com.vrp.model.ChatMessage;
import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;

public class ChatDAO {

    public ChatDAO(String ignored) {}

    // ── CREATE ───────────────────────────────────────────────────────────────
    public void addMessage(ChatMessage msg) throws SQLException {
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "INSERT INTO chat_messages VALUES (?,?,?,?,?,?,?)")) {
            ps.setString(1, msg.getMessageId());
            ps.setString(2, msg.getConversationId());
            ps.setString(3, msg.getFromUsername());
            ps.setString(4, msg.getFromRole());
            ps.setString(5, msg.getContent());
            ps.setString(6, msg.getTimestamp());
            ps.setBoolean(7, msg.isRead());
            ps.executeUpdate();
        }
    }

    // ── READ ─────────────────────────────────────────────────────────────────
    public List<ChatMessage> getAllMessages() throws SQLException {
        List<ChatMessage> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM chat_messages ORDER BY sent_at ASC")) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public List<ChatMessage> getConversation(String conversationId) throws SQLException {
        List<ChatMessage> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT * FROM chat_messages WHERE conversation_id = ? ORDER BY sent_at ASC")) {
            ps.setString(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<ChatMessage> getMessagesSince(String conversationId, String since) throws SQLException {
        return getConversation(conversationId).stream()
            .filter(m -> m.getTimestamp().compareTo(since) > 0)
            .collect(Collectors.toList());
    }

    // ── MARK READ ─────────────────────────────────────────────────────────────
    public void markRead(String conversationId, String readerRole) throws SQLException {
        String sql = "UPDATE chat_messages SET is_read = TRUE " +
                     "WHERE conversation_id = ? AND from_role != ? AND is_read = FALSE";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, conversationId);
            ps.setString(2, readerRole);
            ps.executeUpdate();
        }
    }

    // ── UNREAD COUNTS ─────────────────────────────────────────────────────────
    public long getUnreadCountForCustomer(String conversationId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE conversation_id = ? " +
                     "AND from_role = 'ADMIN' AND is_read = FALSE";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    public long getTotalAdminUnread() throws SQLException {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE from_role = 'CUSTOMER' AND is_read = FALSE";
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }

    // ── CONVERSATION LIST ─────────────────────────────────────────────────────
    public List<Map<String, Object>> getConversationList() throws SQLException {
        List<ChatMessage> all = getAllMessages();
        Map<String, List<ChatMessage>> byConv = new LinkedHashMap<>();
        for (ChatMessage m : all)
            byConv.computeIfAbsent(m.getConversationId(), k -> new ArrayList<>()).add(m);

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, List<ChatMessage>> e : byConv.entrySet()) {
            List<ChatMessage> msgs = e.getValue();
            ChatMessage last = msgs.get(msgs.size() - 1);
            long unread = msgs.stream().filter(m -> !m.isRead() && !m.isFromAdmin()).count();
            Map<String, Object> conv = new LinkedHashMap<>();
            conv.put("conversationId", e.getKey());
            conv.put("lastMessage",    last);
            conv.put("unreadCount",    unread);
            conv.put("messageCount",   msgs.size());
            result.add(conv);
        }
        result.sort((a, b) -> {
            String ta = ((ChatMessage) a.get("lastMessage")).getTimestamp();
            String tb = ((ChatMessage) b.get("lastMessage")).getTimestamp();
            return tb.compareTo(ta);
        });
        return result;
    }

    // ── ID GENERATION ─────────────────────────────────────────────────────────
    public String nextMessageId() throws SQLException {
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(
                 "SELECT message_id FROM chat_messages ORDER BY message_id DESC LIMIT 1")) {
            int max = 0;
            if (rs.next()) {
                String last = rs.getString(1);
                if (last != null && last.startsWith("MSG"))
                    try { max = Integer.parseInt(last.substring(3)); } catch (NumberFormatException ignored) {}
            }
            return String.format("MSG%05d", max + 1);
        }
    }

    private ChatMessage map(ResultSet rs) throws SQLException {
        return new ChatMessage(
            rs.getString("message_id"),
            rs.getString("conversation_id"),
            rs.getString("from_username"),
            rs.getString("from_role"),
            rs.getString("content"),
            rs.getString("sent_at"),
            rs.getBoolean("is_read")
        );
    }
}
