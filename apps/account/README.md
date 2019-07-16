# Exmud.Account

The Account application manages player accounts. It provides an interface for a variety of functions such as creating
accounts, deleting accounts, resetting passwords, verifying email, permissions, and so on. See [Roadmap](roadmap) for further
details.

## <a name="roadmap"></a>Roadmap

### 1.0
  - ~~Account Creation~~
    - ~~Explicit creation such as via a form, where all fields are provided at time of creation~~
  - ~~Authentication~~
    - ~~Username and Password only~~
  - ~~Account Recovery~~
    - ~~Lookup account username via Email~~
    - ~~Token functionality to allow for things like password reset via token sent over email~~
  - Roles
    - Roles provide an Account with domain defined permissions
    - Add/Remove from account
    - Check for existence of role on an account
    - Temporary revocation of a role

### 2.0
  - OAuth 2.0
    - For registration and authentication
  - Billing
    - Subscriptions
    - One time purchases
### Backlog
  - Authentication
    - 2FA
  - Account Notes
    - Text fields to hold arbitrary information about an account. Each note has a metadata field for domain info.