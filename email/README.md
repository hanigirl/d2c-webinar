# Confirmation email after registration

`registration-confirmation.html` is the email that goes out the moment someone
registers. The site itself needs no change — the form already posts name, email,
phone and campaign to the Make webhook, and the scenario already creates the
Brevo contact. The email is one more module in that same scenario.

## The scenario, after this change

    Webhook  →  Brevo: Create a Contact  →  Brevo: Send a transactional email  →  Webhook response

Adding it *before* the webhook response matters: the page waits for that
response before sending the visitor to the thank-you page, so a failure to send
surfaces instead of disappearing.

## Already have the copy as a campaign?

A campaign is a one-off send to a list; it cannot be triggered per registration.
The content still gets reused — it just has to live as a **template**:

- In Brevo open the campaign, **Duplicate → as template**, or copy its HTML into
  a new template. Then follow step 1 from point 4 onward.
- `registration-confirmation.html` in this folder is only a starting point. If
  the campaign copy is the one going out, use that and ignore the file.

## 1 · Load the template into Brevo

1. Brevo → **Campaigns → Templates → New template**.
2. Name it `d2c-webinar · registration confirmation`.
3. Subject: `נרשמת למשדר — נתראה ב-2.9 בשעה 19:30`
4. Design step → **Code your own → Paste your code**, and paste the whole of
   `registration-confirmation.html`.
5. Save and **activate** the template. An inactive template cannot be sent.
6. Note the template id shown in the list — Make needs it.

The greeting uses `{{ contact.FIRSTNAME }}`. Brevo fills it from the contact the
previous module just created, so the "Create a Contact" step must map the
webhook's `firstname` field to the FIRSTNAME attribute. If it is ever empty the
sentence still reads correctly.

## 2 · Add the module in Make

1. Open the scenario, click the arrow between **Brevo — Create a Contact** and
   **Webhooks — Webhook response**, and add **Brevo → Send a transactional
   email** there.
2. Fill it in:
   - **To — email address**: the webhook's `email`
   - **To — name**: the webhook's `fullname`
   - **Template id**: the id from step 1
3. Save and run the scenario once with real details to confirm delivery.

## 3 · Before the first real send

Authenticate the sending domain in Brevo (**Senders, Domains & Dedicated IPs**)
so SPF and DKIM pass for `uxtra.co.il`. Without it a bulk-looking Hebrew email
from a fresh sender lands in spam often enough to matter.

## Editing later

The date appears twice in the template — in the preheader and in the date block.
The webinar's own date lives in `thank-you.html` under `WEBINAR`. Change them
together.
