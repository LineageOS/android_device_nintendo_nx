#!/system/bin/sh

user_state=$(/system/bin/settings get global wifi_on)
sleep 2s
if [ $user_state = "1" ]; then
	svc wifi enable
fi
