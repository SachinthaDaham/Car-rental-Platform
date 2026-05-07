package com.vrp.dao;

import com.vrp.model.ChatMessage;

import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class ChatDAO {

    private final String filePath;

    public ChatDAO(String filePath) {
        this.filePath = filePath;
        ensureFileExists();
    }

    private void ensureFileExists() {
        try {
            File f = new File(filePath);
            File parent = f.getParentFile();
            if (parent != null && !parent.exists()) parent.mkdirs();
            if (!f.exists()) f.createNewFile();
        } catch (IOException e) { e.printStackTrace(); }
    }

    // ── CREATE ────────────────────────────────────────────────────────────────
    public synchronized void addMessage(ChatMessage msg) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, true))) {
            bw.write(msg.toFileString());
            bw.newLine();
        }
    }

    // ── READ ──────────────────────────────────────────────────────────────────
    public synchronized List<ChatMessage> getAllMessages() throws IOException {
        List<ChatMessage> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                ChatMessage m = parseLine(line);
                if (m != null) list.add(m);
            }
        }
        return list;
    }

    public List<ChatMessage> getConversation(String conversationId) throws IOException {
        return getAllMessages().stream()
            .filter(m -> m.getConversationId().equalsIgnoreCase(conversationId))
            .collect(Collectors.toList());
    }

    /** Messages in a conversation that arrived after `since` timestamp. */
    public List<ChatMessage> getMessagesSince(String conversationId, String since) throws IOException {
        return getConversation(conversationId).stream()
            .filter(m -> m.getTimestamp().compareTo(since) > 0)
            .collect(Collectors.toList());
    }

    // ── MARK READ ─────────────────────────────────────────────────────────────
    /**
     * Mark as read messages written by the OTHER side.
     * readerRole = "ADMIN"    → marks CUSTOMER messages as read
     * readerRole = "CUSTOMER" → marks ADMIN messages as read
     */
    public synchronized void markRead(String conversationId, String readerRole) throws IOException {
        List<ChatMessage> all = getAllMessages();
        boolean changed = false;
        for (ChatMessage m : all) {
            if (m.getConversationId().equalsIgnoreCase(conversationId)
                    && !m.isRead()
                    && !m.getFromRole().equals(readerRole)) {
                m.setRead(true);
                changed = true;
            }
        }
        if (changed) writeAll(all);
    }

    // ── UNREAD COUNTS ─────────────────────────────────────────────────────────
    public long getUnreadCountForCustomer(String conversationId) throws IOException {
        return getAllMessages().stream()
            .filter(m -> m.getConversationId().equalsIgnoreCase(conversationId))
            .filter(m -> !m.isRead() && m.isFromAdmin())
            .count();
    }

    public long getTotalAdminUnread() throws IOException {
        return getAllMessages().stream()
            .filter(m -> !m.isRead() && !m.isFromAdmin())
            .count();
    }

    // ── CONVERSATION LIST for admin sidebar ───────────────────────────────────
    public List<Map<String, Object>> getConversationList() throws IOException {
        List<ChatMessage> all = getAllMessages();
        // Group by conversationId preserving insertion order
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
        // Sort newest last-message first
        result.sort((a, b) -> {
            String ta = ((ChatMessage) a.get("lastMessage")).getTimestamp();
            String tb = ((ChatMessage) b.get("lastMessage")).getTimestamp();
            return tb.compareTo(ta);
        });
        return result;
    }

    // ── ID GENERATION ─────────────────────────────────────────────────────────
    public synchronized String nextMessageId() throws IOException {
        return String.format("MSG%05d", getAllMessages().size() + 1);
    }

    // ── Private helpers ───────────────────────────────────────────────────────
    private void writeAll(List<ChatMessage> list) throws IOException {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath, false))) {
            for (ChatMessage m : list) { bw.write(m.toFileString()); bw.newLine(); }
        }
    }

    private ChatMessage parseLine(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 7) return null;
        try {
            return new ChatMessage(p[0], p[1], p[2], p[3], p[4], p[5], "1".equals(p[6]));
        } catch (Exception e) { return null; }
    }
}
