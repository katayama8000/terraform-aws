```ts
const API_ENDPOINT = "https://35c9ddmge9.execute-api.ap-northeast-1.amazonaws.com";
const API_KEY = "your-api-key-here"; // terraform outputで取得した値

// リクエスト例
const response = await fetch(API_ENDPOINT, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': API_KEY  // ← 超重要！
  },
  body: JSON.stringify({ message: "Hello Lambda!" })
});

const data = await response.json();
console.log(data);
```
```rust
// 環境変数からAPI Key取得
let expected_key = std::env::var("API_KEY").expect("API_KEY not set");

// ヘッダーから取得
let client_key = event.headers.get("x-api-key");

// 検証
if client_key != Some(&expected_key) {
    return Ok(Response::builder()
        .status(403)
        .body("Forbidden: Invalid API Key".into())
        .unwrap());
}
```