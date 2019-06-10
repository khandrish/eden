# Exmud.Account

The Account application manages player accounts. It provides an interface for a variety of functions such as creating
accounts, deleting accounts, resetting passwords, verifying email, permissions, and so on. See [Roadmap](roadmap) for further
details.

## <a name="roadmap"></a>Roadmap

### 1.0
  - Account Creation
    - Explicit creation such as via a form, where all fields are provided at time of creation
  - Authentication
    - Username and Password only
  - Account Recovery
    - Lookup account username via Email
    - Update password using a temporary token
  - Account Notes
    - Text fields to hold arbitrary information about an account. Each note has a metadata field for domain info.
  - Roles
    - Hierarchical roles that provide an Account with domain defined permissions
    - Add/Remove from account
    - Edit Description and parent for a role
    - Check for existence of role or parent role on an account
    - Temporary revocation of a role

### 2.0
  - Registration
    - Registration via third parties such as Google via OAuth 2.0
  - Authentication
    - OAuth 2.0
  - Billing
    - Subscriptions
    - One time purchases
### Backlog
  - Authentication
    - 2FA