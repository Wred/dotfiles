#!/bin/bash

set -efuo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

