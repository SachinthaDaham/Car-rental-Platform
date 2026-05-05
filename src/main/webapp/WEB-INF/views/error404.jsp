<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<% request.setAttribute("pageTitle", "Page Not Found — DriveLanka"); %>
<%@ include file="header.jspf" %>

<div class="min-h-[70vh] flex items-center justify-center px-4">
  <div class="text-center max-w-md">
    <div class="text-[120px] font-extrabold text-slate-100 leading-none select-none">404</div>
    <div class="-mt-6">
      <div class="w-24 h-24 mx-auto mb-6 rounded-full bg-brand-50 flex items-center justify-center">
        <i class="bi bi-sign-stop text-brand-400 text-5xl"></i>
      </div>
      <h1 class="text-3xl font-extrabold text-ink-900 mb-3">Page Not Found</h1>
      <p class="text-slate-500 mb-8">Looks like you took a wrong turn. The page you're looking for doesn't exist or has moved.</p>
      <div class="flex flex-wrap gap-3 justify-center">
        <a href="${pageContext.request.contextPath}/" class="bg-brand-600 hover:bg-brand-700 text-white font-bold px-6 py-2.5 rounded-xl shadow-btn transition flex items-center gap-2">
          <i class="bi bi-house-fill"></i> Go Home
        </a>
        <a href="${pageContext.request.contextPath}/vehicles?action=browse" class="bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-bold px-6 py-2.5 rounded-xl transition flex items-center gap-2">
          <i class="bi bi-search"></i> Browse Fleet
        </a>
      </div>
    </div>
  </div>
</div>

<%@ include file="footer.jspf" %>
