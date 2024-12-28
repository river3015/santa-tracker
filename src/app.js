// 地図の初期化（日本全体が見えるように調整）
const map = L.map('map').setView([38.0, 137.0], 5); // 緯度、経度、ズームレベルを調整

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors'
}).addTo(map);

let marker = null;

// サンタのアイコンを定義
const santaIcon = L.icon({
    iconUrl: './santa-icon.png',
    iconSize: [46, 46],
    iconAnchor: [23, 23],  // iconSizeの半分の値に調整
    popupAnchor: [0, -23]  // アンカーポイントの上に表示
});

// サンタの位置を更新する関数
async function updateSantaLocation() {
    try {
        // APIエンドポイントを取得
        const API_ENDPOINT = window.SANTA_TRACKER_API_ENDPOINT;
        console.log('API Endpoint:', API_ENDPOINT); // デバッグ用に追加

        const response = await fetch(API_ENDPOINT);
        const data = await response.json();
        console.log('API Response:', data); // デバッグ用

        // データの構造を確認
        if (!data.location) {
            console.error('Location data not found in response');
            return;
        }

        const location = data.location;
        console.log('Location data:', location); // デバッグ用

        const lat = parseFloat(location.latitude);
        const lng = parseFloat(location.longitude);

        // 座標が有効か確認
        if (isNaN(lat) || isNaN(lng)) {
            console.error('Invalid coordinates:', location);
            return;
        }

        // 既存のマーカーを削除
        if (marker) {
            map.removeLayer(marker);
        }

        // 新しいマーカーを追加（一時的にデフォルトアイコンを使用）
        marker = L.marker([lat, lng]).addTo(map);

        // タイムスタンプを表示
        const timestamp = new Date(location.timestamp).toLocaleString('ja-JP');
        marker.bindPopup(`最終更新: ${timestamp}`).openPopup();

    } catch (error) {
        console.error('Error fetching Santa location:', error);
    }
}

// 初回実行
updateSantaLocation();

// 定期的に位置情報を更新（2秒ごと）
setInterval(updateSantaLocation, 2000);