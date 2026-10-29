# Checking email authentication with real headers

DNS lookups can show SPF and DMARC, but they can't prove whether outgoing mail is DKIM-signed. Providers use selector names you can't guess. The reliable check is to look at an email that was actually sent from the domain.

## How to get the headers

Ask the business to send any short email from their domain to an address you control. Or use an email they already sent you. Then:

- **Gmail:** open the message, click the three dots, then **Show original**.
- **Outlook (web):** open the message, click the three dots, then **View** and **View message source**.
- **Apple Mail:** **View** menu, then **Message**, then **Raw Source**.

Copy only the authentication lines (`Authentication-Results`, `ARC-Authentication-Results`, `Received-SPF`) into `reviews/<run>/evidence/email-headers.txt`. Leave out message content and anyone's private details.

## How to read them

| Line contains | Meaning |
|---|---|
| `spf=pass` | The sending server is allowed by the domain's SPF record. |
| `dkim=pass header.d=<their domain>` | The message was signed by the domain. Good. |
| `dkim=none (message not signed)` | No signature arrived. DMARC can then pass only on SPF, which breaks when mail is forwarded. Recommend turning on DKIM signing with their mail provider. |
| `dmarc=pass` | The domain's DMARC policy was satisfied. |
| `compauth=pass` | Microsoft's combined check passed. |

If the message passed through a filtering gateway (for example Proofpoint or Mimecast), an earlier hop may show `dkim=pass` while the final result shows `dkim=none`. Report the final result, and suggest checking the gateway's outbound signing setting.
