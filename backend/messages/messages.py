from twilio.rest import Client
import os
# Find your Account SID and Auth Token in Account Info and set the environment variables.
# See http://twil.io/secure
__account_sid = "ACfed3893d93fce93b491e2203ab158cd6"
__auth_token = "0be2e556d4108c361adb448f042c801d"
__client = Client(__account_sid, __auth_token)

def messages_sendMessage(recipients: list, body: str) -> str:
    messages_sids = []
    for recipient in recipients:
        message = __client.messages.create(
            body=body, 
            from_='+19458003872',
            to=recipient
        )
        print(message.sid)
        messages_sids.append(message.sid)
    return messages_sids