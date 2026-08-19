importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCAI6Jo7OvV8CXSePhgA_bEPM7LEa3fea0",
  appId: "1:31352192762:web:64395abc0e292cedb1d343",
  messagingSenderId: "31352192762",
  projectId: "gadget-world-a1a2c",
  authDomain: "gadget-world-a1a2c.firebaseapp.com",
  storageBucket: "gadget-world-a1a2c.firebasestorage.app"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title || 'Gadget Store';
  const notificationOptions = {
    body: payload.notification?.body,
    icon: '/favicon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
