importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAqWxl7WMhcmILNWDg6__6KfdAENhVfCeM",
  projectId: "comp205-lab5-zeynep-3705e",
  messagingSenderId: "199255041584",
  appId: "1:199255041584:web:fe323a7c23e1855b002ff5"
});

const messaging = firebase.messaging();