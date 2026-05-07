package com.vrp.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ChatMessage {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private String  messageId;
    private String  conversationId;  // = customerUsername
    private String  fromUsername;
    private String  fromRole;        // CUSTOMER | ADMIN
    private String  content;
    private String  timestamp;       // yyyy-MM-dd HH:mm:ss
    private boolean read;

    public ChatMessage() {}

    public ChatMessage(String messageId, String conversationId, String fromUsername,
                       String fromRole, String content, String timestamp, boolean read) {
        this.messageId      = messageId;
        this.conversationId = conversationId;
        this.fromUsername   = fromUsername;
        this.fromRole       = fromRole;
        this.content        = content;
        this.timestamp      = timestamp;
        this.read           = read;
    }

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public String  getMessageId()      { return messageId; }
    public String  getConversationId() { return conversationId; }
    public String  getFromUsername()   { return fromUsername; }
    public String  getFromRole()       { return fromRole; }
    public String  getContent()        { return content; }
    public String  getTimestamp()      { return timestamp; }
    public boolean isRead()            { return read; }
    public void    setRead(boolean v)  { read = v; }

    public boolean isFromAdmin() { return "ADMIN".equals(fromRole); }

    /** Short time for chat bubbles, e.g. "14:32" */
    public String getShortTime() {
        if (timestamp == null || timestamp.length() < 16) return "";
        return timestamp.substring(11, 16);
    }

    public static String nowTimestamp() {
        return LocalDateTime.now().format(FMT);
    }

    public String toFileString() {
        return String.join("|",
            safe(messageId), safe(conversationId), safe(fromUsername),
            safe(fromRole), safe(content), safe(timestamp),
            read ? "1" : "0");
    }

    private static String safe(String s) {
        return s == null ? "" : s.replace("|", "/").replace("\n", " ").replace("\r", "");
    }
}
