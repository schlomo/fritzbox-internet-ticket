#!/usr/bin/env python3
# GOOGLE_APPLICATION_CREDENTIALS env variable should point to the JSON of a service account
# GOOGLE_PROJECT_ID is the project ID
#
# On Ubuntu/Debian you might need this also:
# GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=/etc/ssl/certs/ca-certificates.crt
#
# Purpose:
# Listen to a Google Cloud Pub/Sub topic and print an internet ticket for each received message.
# Usecase is printing tickets if you are not home, e.g. for a child.

import time
import os

import sh

from google.cloud import pubsub_v1

def callback(message):
    print('Received message: {}'.format(message.data))
    message.ack()
    sh.fritzbox_internet_ticket()

subscriber = pubsub_v1.SubscriberClient()

subscription_path = subscriber.subscription_path(
    os.getenv("GOOGLE_PROJECT_ID"), os.getenv("SUBSCRIPTION_NAME", "print-ticket"))

subscription = subscriber.subscribe(subscription_path, callback=callback)

try:
    print("Waiting for messages...")
    subscription.result()
except KeyboardInterrupt:
    pass
except Exception as e:
    print(
        'Listening for messages on {} threw an Exception: {}.'.format(
            subscription_path, e))
