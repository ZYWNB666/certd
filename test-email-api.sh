#!/bin/bash
# 测试自定义邮件 API

echo "======================================"
echo "测试自定义邮件 API"
echo "======================================"
echo ""

# 邮件 API 配置
API_URL="https://mail.netwebs.top/send"
TOKEN="token-0hfgh80cb58e388fac923965hib0"

# 获取测试邮箱地址
read -p "请输入测试邮箱地址: " EMAIL

if [ -z "$EMAIL" ]; then
    echo "❌ 邮箱地址不能为空"
    exit 1
fi

echo ""
echo "发送测试邮件到: $EMAIL"
echo "使用 API: $API_URL"
echo ""

# 发送测试邮件
RESPONSE=$(curl -s -X POST "$API_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "mail=$EMAIL&subject=Certd 邮件测试&html_content=<h1>测试邮件</h1><p>这是来自 Certd 的测试邮件。</p><p>如果你收到这封邮件，说明邮件服务配置成功！</p>")

echo "API 响应:"
echo "$RESPONSE"
echo ""

# 检查响应
if echo "$RESPONSE" | grep -q "success"; then
    echo "✅ 邮件发送成功！请检查你的邮箱。"
else
    echo "❌ 邮件发送失败！"
    echo "请检查："
    echo "  1. Token 是否正确"
    echo "  2. 邮箱地址是否有效"
    echo "  3. API 服务是否正常"
fi

echo ""

