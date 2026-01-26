// Service Worker - 缓存策略
const CACHE_NAME = 'oil-system-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json'
];

// 安装 Service Worker
self.addEventListener('install', event => {
  console.log('[Service Worker] 安装中...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] 缓存已打开');
        return cache.addAll(urlsToCache);
      })
      .catch(err => {
        console.error('[Service Worker] 缓存失败:', err);
      })
  );
  // 强制跳过等待,立即激活
  self.skipWaiting();
});

// 激活 Service Worker
self.addEventListener('activate', event => {
  console.log('[Service Worker] 激活中...');
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            console.log('[Service Worker] 删除旧缓存:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  // 立即控制所有页面
  return self.clients.claim();
});

// 拦截请求
self.addEventListener('fetch', event => {
  // 只缓存 GET 请求
  if (event.request.method !== 'GET') {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // 缓存命中,返回缓存
        if (response) {
          return response;
        }

        // 克隆请求
        const fetchRequest = event.request.clone();

        return fetch(fetchRequest).then(response => {
          // 检查是否是有效响应
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          // 克隆响应
          const responseToCache = response.clone();

          // 缓存新资源
          caches.open(CACHE_NAME)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });

          return response;
        });
      })
      .catch(err => {
        console.error('[Service Worker] 请求失败:', err);
      })
  );
});
