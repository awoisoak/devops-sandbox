import os
import smtplib

# https://support.google.com/accounts/answer/185833?hl=en
DEVOPS_EMAIL_ADDRESS = os.environ.get("DEVOPS_EMAIL_ADDRESS")
DEVOPS_EMAIL_PASSWORD = os.environ.get("DEVOPS_EMAIL_PASSWORD")


def send_alert(msg):
    """ Send email alert to the specified account"""
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.starttls()
        smtp.ehlo()
        smtp.login(DEVOPS_EMAIL_ADDRESS, DEVOPS_EMAIL_PASSWORD)
        smtp.sendmail(
            from_addr=DEVOPS_EMAIL_ADDRESS,
            to_addrs=DEVOPS_EMAIL_ADDRESS,
            msg=msg
        )
        print("Email sent")
