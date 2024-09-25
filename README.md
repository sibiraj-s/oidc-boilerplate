# OIDC Setup with Ory Hydra and AWS STS

This repository demonstrates how to use the OIDC Client Credentials Flow with [Ory Hydra](https://www.ory.sh/hydra/docs/) (an open-source OAuth2 and OpenID Connect server) and assume a role in AWS using AWS Security Token Service (STS).

It provides two scripts for this purpose:

- **`generate.sh`**: Generates an access token using the OIDC Client Credentials Flow.
- **`assume.sh`**: Assumes a role from AWS using AWS STS

> [!IMPORTANT]
> This setup is for demonstration purposes only. In a production environment, ensure that your configuration meets your security requirements.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [tunnelmole](https://tunnelmole.com/) or similar tunneling services (e.g., ngrok, localtunnel)
- [AWS Account](https://aws.amazon.com/)

### Start the tunnelmole Server

To make Ory Hydra accessible over the internet, you can use tunnelmole or a similar service like ngrok or localtunnel.

Start the tunnelmole server with the following command:

```bash
npx tunnelmole 4444
```

Once the server is running, it will generate a public URL. Copy this URL and replace the `issuer` URL in the [hydra.yml](./config/hydra.yml) configuration file. Ensure the URL uses `https` protocol.

> [!NOTE]
> If you use an alternate service like ngrok, ensure it doesn't add any interstitial pages (i.e., extra steps like a click-through page). These can interfere with AWS OpenID provider setup. For example, check [ngrok's guide on interstitials](https://ngrok.com/docs/guides/limits/#why-is-there-an-interstitial-in-front-of-my-html-content) for more information.

### Start the Hydra Server

Before starting, verify and update the values in [hydra.yml](./config/hydra.yml) as needed.

Start the Hydra server using Docker Compose:

```bash
docker compose up
```

On the first boot, this command will apply the necessary database migrations and start the Hydra server.

### Configure the OIDC Provider in AWS

**Step 1: Create the OpenID Connect Provider in AWS**

1. Open the **IAM** dashboard in the AWS Management Console.
2. Select **Identity Providers** from the left-hand menu.
3. Click **Create Provider**.
4. Choose **OpenID Connect** as the provider type.
5. Paste the public `https` URL (from tunnelmole or similar) into the **Provider URL** field.
6. Set the **Audience** field to `sts.amazonaws.com`.
7. Click **Create**.

**Step 2: Create a Role for the OIDC Provider**

1. In the **IAM** dashboard, select **Roles**.
2. Click **Create Role**.
3. Choose **Web Identity** as the trusted entity type.
4. Select the newly created OpenID Connect provider, and ensure the audience is set to `sts.amazonaws.com`.
5. Attach a policy to the role. You can either create a new policy or use an existing one.
6. Provide a name for the role, review the configuration, and create the role.

> [!NOTE]
> In a production setup, you may want to configure more attributes in the trust policy, such as limiting the `sub` (subject) to scope down access for the client.

### Create OIDC Client

Before generating the OIDC client, copy the Amazon Resource Name (ARN) of the role you just created in AWS and add it to the `.env` file:

```bash
export ROLE_ARN=arn:aws:iam::Accountxxx:role/OIDCProvider
```

Refer to [sample.env](./sample.env) for an example.

Once the `.env` file is set up, run the `generate.sh` script to create an OIDC client:

```bash
sh ./generate.sh
```

This script will generate an OIDC client, including its client ID, secret, and access token. These values will be written to the `.env` file.

### Assume the Role

Now, you can use the `assume.sh` script to assume the AWS role:

```bash
sh ./assume.sh
```

This will use the generated access token to assume the role, and the assumed role session credentials will be printed in the terminal.
