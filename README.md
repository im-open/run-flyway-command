# run-flyway-command

A GitHub Action that will run [Flyway](https://flywaydb.org/) against a specified database. Flyway must be installed in order for this Action to work. The [setup-flyway](https://github.com/im-open/setup-flyway) Action can be used for that purpose.

## Index <!-- omit in toc -->

- [run-flyway-command](#run-flyway-command)
  - [Inputs](#inputs)
  - [Usage Examples](#usage-examples)
  - [Contributing](#contributing)
    - [Incrementing the Version](#incrementing-the-version)
    - [Source Code Changes](#source-code-changes)
    - [Updating the README.md](#updating-the-readmemd)
  - [Code of Conduct](#code-of-conduct)
  - [License](#license)

## Inputs

| Parameter                               | Is Required | Default | Description                                                                                                                                                                                                                                |
| --------------------------------------- | ----------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `db-server-name`                        | true        | N/A     | The database server name.                                                                                                                                                                                                                  |
| `db-server-port`                        | false       | 1433    | The port the database server listens on.                                                                                                                                                                                                   |
| `db-name`                               | true        | N/A     | The name of the database to run flyway against.                                                                                                                                                                                            |
| `trust-server-certificate`              | false       | false   | A boolean that controls whether or not to validate the SQL Server TLS certificate.                                                                                                                                                         |
| `migration-files-path`                  | true        | N/A     | The path to the base directory containing the migration files to have flyway process.                                                                                                                                                      |
| `flyway-command`                        | true        | N/A     | The flyway command to run; e.g `migrate`, `validate`, etc.                                                                                                                                                                                 |
| `migration-history-table`               | true        | N/A     | The table where the migration history lives. This is most likely dbo.MigrationHistory or Flyway.MigrationHistory.                                                                                                                          |
| `baseline-version`                      | false       | 0       | The baseline version to send to the flyway command.                                                                                                                                                                                        |
| `managed-schemas`                       | true        | N/A     | A comma separated list of schemas that are to be managed by Flyway.MigrationHistory.                                                                                                                                                       |
| `enable-out-of-order`                   | false       | false   | A switch that allows new migrations that are a lower version number than a current migration to be run.                                                                                                                                    |
| `validate-migrations`                   | false       | true    | A switch determining whether flyway should validate the migration scripts before running them.                                                                                                                                             |
| `use-integrated-security`               | false       | false   | A switch defining whether or not to use integrated security. If not provided, a password should be.                                                                                                                                        |
| `use-azure-service-principal`           | false       | false   | A switch to indicate that an Azure Active Directory Service Principal will be used to authenticate with the SQL Server.                                                                                                                    |
| `use-azure-service-principal-federated` | false       | false   | A switch to indicate that an Azure Active Directory Service Principal will be used to authenticate with the SQL using the federated credentials. You must set the input `enable-AzPSSession: true` on Azure Login Step.                    |
| `username`                              | false       | N/A     | The username of the user making the changes, which is put into the MigrationHistory table, and also to login with if not using integrated security. This should be the Service Principal ID if use-azure-service-principal is set to true. |
| `password`                              | false       | N/A     | The password for the user making changes if not using integrated security. This should be the Service Principal Secret if use-azure-service-principal is set to true.                                                                      |
| `extra-parameters`                      | false       | N/A     | A string containing anything extra that should be added to the flyway command.                                                                                                                                                             |

## Usage Examples

**Using user/password authentication**

```yml
jobs:
  migrate-database:
    runs-on: [self-hosted, windows-2019]
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Flyway
        uses: actions/setup-flyway@v1.1.0
        with:
          version: 5.1.4

      - name: Run Flyway Migrations
        # You may also reference the major or major.minor version
        uses: im-open/run-flyway-command@v1.5.0
        with:
          db-server-name: "localhost"
          db-server-port: "1433"
          db-name: "LocalDb"
          trust-server-certificate: "true"
          migration-files-path: "./src/Database/Migrations"
          flyway-command: "migrate"
          migration-history-table: "dbo.MigrationHistory"
          baseline-version: "0"
          managed-schemas: "dbo,MyCustomSchema"
          enable-out-of-order: "true"
          use-integrated-security: "false"
          username: "database-user"
          password: "${{ secrets.DbUserPassword }}"
          extra-parameters: "-lockRetryCount=20 -dryRunOutput=./dry-run-output"
```

**Using Azure Service Principal authentication**

```yml
jobs:
  migrate-database:
    runs-on: [self-hosted, windows-2019]
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Flyway
        uses: actions/setup-flyway@v1.1.0
        with:
          version: 5.1.4

      - name: Run Flyway Migrations
        # You may also reference the major or major.minor version
        uses: im-open/run-flyway-command@v1.5.0
        with:
          db-server-name: "localhost"
          db-server-port: "1433"
          db-name: "LocalDb"
          trust-server-certificate: "true"
          migration-files-path: "./src/Database/Migrations"
          flyway-command: "migrate"
          migration-history-table: "dbo.MigrationHistory"
          baseline-version: "0"
          managed-schemas: "dbo,MyCustomSchema"
          enable-out-of-order: "true"
          use-azure-service-principal: "true"
          username: "${{ secrets.AZ_SERVICE_PRINCIPAL_ID }}"
          password: "${{ secrets.AZ_SERVICE_PRINCIPAL_SECRET }}"
```

**Using Azure Service Principal authentication with Federated Token**

```yml
jobs:
  migrate-database:
    runs-on: [self-hosted, windows-2019]
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Flyway
        uses: actions/setup-flyway@v1.1.0
        with:
          version: 5.1.4

      - name: AZ Login
        uses: azure/login@v1
        with:
          # This is an org-level variable
          tenant-id: ${{ vars.ARM_TENANT_ID }}
          # These are env-level variables
          subscription-id: ${{ vars.ARM_SUBSCRIPTION_ID }}
          client-id: ${{ vars.ARM_CLIENT_ID }}
          enable-AzPSSession: true

      - name: Run Flyway Migrations
        # You may also reference the major or major.minor version
        uses: im-open/run-flyway-command@v1.5.0
        with:
          db-server-name: "localhost"
          db-server-port: "1433"
          db-name: "LocalDb"
          trust-server-certificate: "true"
          migration-files-path: "./src/Database/Migrations"
          flyway-command: "migrate"
          migration-history-table: "dbo.MigrationHistory"
          baseline-version: "0"
          managed-schemas: "dbo,MyCustomSchema"
          enable-out-of-order: "true"
          use-azure-service-principal-federated: "true"
          username: "${{ vars.ARM_CLIENT_ID  }}"
```

## Contributing

When creating PRs, please review the following guidelines:

<<<<<<< Updated upstream

- [ ] The action code does not contain sensitive information.
- [ ] At least one of the commit messages contains the appropriate `+semver:` keywords listed under [Incrementing the Version] for major and minor increments.
- [ ] The README.md has been updated with the latest version of the action. See [Updating the README.md] for details.

### Incrementing the Version

This repo uses [git-version-lite] in its workflows to examine commit messages to determine whether to perform a major, minor or patch increment on merge if [source code] changes have been made. The following table provides the fragment that should be included in a commit message to active different increment strategies.

| Increment Type | Commit Message Fragment                     |
| -------------- | ------------------------------------------- |
| major          | +semver:breaking                            |
| major          | +semver:major                               |
| minor          | +semver:feature                             |
| minor          | +semver:minor                               |
| patch          | _default increment type, no comment needed_ |

=======

1. For major or minor changes, at least one of the commit messages contains the appropriate `+semver:` keywords listed under [Incrementing the Version](#incrementing-the-version).
1. The action code does not contain sensitive information.

When a pull request is created and there are changes to code-specific files and folders, the `auto-update-readme` workflow will run. The workflow will update the action-examples in the README.md if they have not been updated manually by the PR author. The following files and folders contain action code and will trigger the automatic updates:

- `action.yml`
- `src/**`

There may be some instances where the bot does not have permission to push changes back to the branch though so this step should be done manually for those branches. See [Incrementing the Version](#incrementing-the-version) for more details.

### Incrementing the Version

The `auto-update-readme` and PR merge workflows will use the strategies below to determine what the next version will be. If the `auto-update-readme` workflow was not able to automatically update the README.md action-examples with the next version, the README.md should be updated manually as part of the PR using that calculated version.

This action uses [git-version-lite] to examine commit messages to determine whether to perform a major, minor or patch increment on merge. The following table provides the fragment that should be included in a commit message to active different increment strategies.
| Increment Type | Commit Message Fragment |
| -------------- | ------------------------------------------- |
| major | +semver:breaking |
| major | +semver:major |
| minor | +semver:feature |
| minor | +semver:minor |
| patch | _default increment type, no comment needed_ |

> > > > > > > Stashed changes

### Source Code Changes

The files and directories that are considered source code are listed in the `files-with-code` and `dirs-with-code` arguments in both the [build-and-review-pr] and [increment-version-on-merge] workflows.

If a PR contains source code changes, the README.md should be updated with the latest action version. The [build-and-review-pr] workflow will ensure these steps are performed when they are required. The workflow will provide instructions for completing these steps if the PR Author does not initially complete them.

If a PR consists solely of non-source code changes like changes to the `README.md` or workflows under `./.github/workflows`, version updates do not need to be performed.

### Updating the README.md

If changes are made to the action's [source code], the [usage examples] section of this file should be updated with the next version of the action. Each instance of this action should be updated. This helps users know what the latest tag is without having to navigate to the Tags page of the repository. See [Incrementing the Version] for details on how to determine what the next version will be or consult the first workflow run for the PR which will also calculate the next version.

## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/main/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2023, Extend Health, LLC. Code released under the [MIT license](LICENSE).

<!-- Links -->

[Incrementing the Version]: #incrementing-the-version
[Updating the README.md]: #updating-the-readmemd
[source code]: #source-code-changes
[usage examples]: #usage-examples
[build-and-review-pr]: ./.github/workflows/build-and-review-pr.yml
[increment-version-on-merge]: ./.github/workflows/increment-version-on-merge.yml
[git-version-lite]: https://github.com/im-open/git-version-lite
