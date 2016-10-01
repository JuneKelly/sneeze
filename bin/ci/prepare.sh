#!/bin/bash

# NOTE: Keep in mind that this script does not verify the shasum of the downloads.

# NOTE: Don't forget to make this file executable or the build won't run

set -e

export ERLANG_VERSION="19.0"
export ELIXIR_VERSION="v1.3.2"

# If you have a elixir_buildpack.config, do this instead:
#export ERLANG_VERSION=$(cat elixir_buildpack.config | grep erlang_version | tr "=" " " | awk '{ print $2 }')
#export ELIXIR_VERSION=v$(cat elixir_buildpack.config | grep elixir_version | tr "=" " " | awk '{ print $2 }')

export INSTALL_PATH="$HOME/dependencies"

export ERLANG_PATH="$INSTALL_PATH/otp_src_$ERLANG_VERSION"
export ELIXIR_PATH="$INSTALL_PATH/elixir_$ELIXIR_VERSION"

mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# Install erlang
if [ ! -e $ERLANG_PATH/bin/erl ]; then
  curl -L -O http://www.erlang.org/download/otp_src_$ERLANG_VERSION.tar.gz
  tar xzf otp_src_$ERLANG_VERSION.tar.gz
  cd $ERLANG_PATH
  ./configure --enable-smp-support \
              --enable-m64-build \
              --disable-native-libs \
              --disable-sctp \
              --enable-threads \
              --enable-kernel-poll \
              --disable-hipe \
              --without-javac
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ERLANG_PATH $INSTALL_PATH/erlang
fi

# Install elixir
export PATH="$ERLANG_PATH/bin:$PATH"

if [ ! -e $ELIXIR_PATH/bin/elixir ]; then
  git clone https://github.com/elixir-lang/elixir $ELIXIR_PATH
  cd $ELIXIR_PATH
  git checkout $ELIXIR_VERSION
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ELIXIR_PATH $INSTALL_PATH/elixir
fi

export PATH="$ERLANG_PATH/bin:$ELIXIR_PATH/bin:$PATH"

# Install package tools
if [ ! -e $HOME/.mix/rebar ]; then
  yes Y | LC_ALL=en_GB.UTF-8 mix local.hex
  yes Y | LC_ALL=en_GB.UTF-8 mix local.rebar
fi

# If you use Elm:
# 1) add the code below
# 2) run the Elm build like this " ~/dependencies/sysconfcpus/bin/sysconfcpus -n 2 node_modules/brunch/bin/brunch build"
# 3) your Elm builds will finish in seconds instead of minutes
#
# For more info see: https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-245704142
#if [ ! -d $INSTALL_PATH/sysconfcpus/bin ]; then
#  git clone https://github.com/obmarg/libsysconfcpus.git
#  cd libsysconfcpus
#  ./configure --prefix=$INSTALL_PATH/sysconfcpus
#  make && make install
#  cd ..
#fi

# Fetch and compile dependencies and application code (and include testing tools)
export MIX_ENV="test"
cd $HOME/$CIRCLE_PROJECT_REPONAME
mix do deps.get, deps.compile, compile
