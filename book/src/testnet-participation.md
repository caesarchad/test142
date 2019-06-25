## Testnet Participation
This document describes how to participate in the testnet as a
validator node.

Please note some of the information and instructions described here may change
in future releases.

### Overview
The testnet features a validator running at testnet.solana.com, which
serves as the entrypoint to the cluster for your validator.

Additionally there is a blockexplorer available at
[http://testnet.solana.com/](http://testnet.solana.com/).

The testnet is configured to reset the ledger daily, or sooner
should the hourly automated cluster sanity test fail.

There is a **#validator-support** Discord channel available to reach other
testnet participants, https://discord.gg/pquxPsq.

Also we'd love it if you choose to register your validator node with us at
https://forms.gle/LfFscZqJELbuUP139.

### Machine Requirements
Since the testnet is not intended for stress testing of max transaction
throughput, a higher-end machine with a GPU is not necessary to participate.

However ensure the machine used is not behind a residential NAT to avoid NAT
traversal issues.  A cloud-hosted machine works best.  **Ensure that IP ports
8000 through 10000 are not blocked for Internet inbound and outbound traffic.**

Prebuilt binaries are available for Linux x86_64 (Ubuntu 18.04 recommended).
MacOS or WSL users may build from source.

#### Confirm The Testnet Is Reachable
Before attaching a validator node, sanity check that the cluster is accessible
to your machine by running some simple commands.  If any of the commands fail,
please retry 5-10 minutes later to confirm the testnet is not just restarting
itself before debugging further.

Fetch the current transaction count over JSON RPC:
```bash
$ curl -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getTransactionCount"}' http://testnet.solana.com:8899
```

Inspect the blockexplorer at [http://testnet.solana.com/](http://testnet.solana.com/) for activity.

View the [metrics dashboard](
https://metrics.solana.com:3000/d/testnet-beta/testnet-monitor-beta?var-testnet=testnet)
for more detail on cluster activity.

### Validator Setup
#### Obtaining The Software
##### Bootstrap with `solana-install`

The `solana-install` tool can be used to easily install and upgrade the cluster
software on Linux x86_64 systems.

```bash
$ export SOLANA_RELEASE=v0.14.1  # skip this line to install the latest release
$ curl -sSf https://raw.githubusercontent.com/solana-labs/solana/v0.14.1/install/solana-install-init.sh | sh -s
```

Alternatively build the `solana-install` program from source and run the
following command to obtain the same result:
```bash
$ solana-install init
```

After a successful install, `solana-install update` may be used to easily update the cluster
software to a newer version.

##### Download Prebuilt Binaries
Binaries are available for Linux x86_64 systems.

Download the binaries by navigating to
[https://github.com/solana-labs/solana/releases/latest](https://github.com/solana-labs/solana/releases/latest),
download **solana-release-x86_64-unknown-linux-gnu.tar.bz2**, then extract the
archive:
```bash
$ tar jxf solana-release-x86_64-unknown-linux-gnu.tar.bz2
$ cd solana-release/
$ export PATH=$PWD/bin:$PATH
```
##### Build From Source
If you are unable to use the prebuilt binaries or prefer to build it yourself
from source, navigate to
[https://github.com/solana-labs/solana/releases/latest](https://github.com/solana-labs/solana/releases/latest),
and download the **Source Code** archive.  Extract the code and build the
binaries with:
```bash
$ ./scripts/cargo-install-all.sh .
$ export PATH=$PWD/bin:$PATH
```

### Starting The Validator
Sanity check that you are able to interact with the cluster by receiving a small
airdrop of lamports from the testnet drone:
```bash
$ solana-wallet -n testnet.solana.com airdrop 123
$ solana-wallet -n testnet.solana.com balance
```

Also try running following command to join the gossip network and view all the other nodes in the cluster:
```bash
$ solana-gossip --network testnet.solana.com:8001 spy
# Press ^C to exit
```

Now configure a key pair for your validator by running:
```bash
$ solana-keygen -o fullnode-keypair.json
```

Then use one of the following commands, depending on your installation
choice, to start the node:

If this is a `solana-install`-installation:
```bash
$ clear-fullnode-config.sh
$ fullnode.sh --identity fullnode-keypair.json --poll-for-new-genesis-block testnet.solana.com
```

Alternatively, the `solana-install run` command can be used to run the validator
node while periodically checking for and applying software updates:
```bash
$ clear-fullnode-config.sh
$ solana-install run fullnode.sh -- --identity fullnode-keypair.json --poll-for-new-genesis-block testnet.solana.com
```

If you built from source:
```bash
$ USE_INSTALL=1 ./multinode-demo/clear-fullnode-config.sh
$ USE_INSTALL=1 ./multinode-demo/fullnode.sh --identity fullnode-keypair.json --poll-for-new-genesis-block testnet.solana.com
```

#### Controlling local network port allocation
By default the validator will dynamically select available network ports in the
8000-10000 range, and may be overridden with `--dynamic-port-range`.  For
example, `fullnode.sh --dynamic-port-range 11000-11010 ...` will restrict the
validator to ports 11000-11011.

### Validator Monitoring
When `fullnode.sh` starts, it will output a fullnode configuration that looks
similar to:
```bash
======================[ Fullnode configuration ]======================
node pubkey: 4ceWXsL3UJvn7NYZiRkw7NsryMpviaKBDYr8GK7J61Dm
vote pubkey: 2ozWvfaXQd1X6uKh8jERoRGApDqSqcEy6fF1oN13LL2G
ledger: ...
accounts: ...
======================================================================
```

The **node pubkey** for your validator can also be found by running:
```bash
$ solana-keygen pubkey fullnode-keypair.json
```

From another console, confirm the IP address of your validator is visible in the
gossip network by running:
```bash
$ solana-gossip --network testnet.solana.com:8001 spy
```

Provide the **vote pubkey** to the `solana-wallet show-vote-account` command to view
the recent voting activity from your validator:
```bash
$ solana-wallet -n testnet.solana.com show-vote-account 2ozWvfaXQd1X6uKh8jERoRGApDqSqcEy6fF1oN13LL2G
```

The vote pubkey for the validator can also be found by running:
```bash
# If this is a `solana-install`-installation run:
$ solana-keygen pubkey ~/.local/share/solana/install/active_release/config-local/fullnode-vote-keypair.json
# Otherwise run:
$ solana-keygen pubkey ./config-local/fullnode-vote-keypair.json
```

### Sharing Metrics From Your Validator
If you have obtained a metrics username/password from the Solana maintainers to
help us monitor the health of the testnet, please perform the following steps
before starting the validator node to activate metrics reporting:
```bash
export u="username obtained from the Solana maintainers"
export p="password obtained from the Solana maintainers"
export SOLANA_METRICS_CONFIG="db=testnet,u=${u:?},p=${p:?}"
source scripts/configure-metrics.sh
```