#!/bin/sh

# PREPARATION
export DEBIAN_FRONTEND="noninteractive"

if [ "$SRC_DIR" == "" ]; then
	if [ -e "/vagrant" ]; then
        export SRC_DIR="/vagrant"
	else
		export SRC_DIR="$(pwd)"
	fi
fi

export WILDFLY_DESTDIR="/opt"
export WILDFLY_HOME="$WILDFLY_DESTDIR/wildfly"
export WILDFLY_VERSION="8.2.1.Final"
export WILDFLY_PKG_DIR=wildfly-$WILDFLY_VERSION
export WILDFLY_PKG="$WILDFLY_PKG_DIR.tar.gz"
export WILDFLY_PKG_URL="http://download.jboss.org/wildfly/$WILDFLY_VERSION/$WILDFLY_PKG"
export WILDFLY_USER="wildfly"
export WILDFLY_SERVICE="$WILDFLY_USER"

export PUPPET_APTPKG="puppetlabs-release-pc1-precise.deb"
export PUPPET_APTPKG_URL="https://apt.puppetlabs.com/$PUPPET_APTPKG"

export CHEFDK_VERSION="0.7.0-1_amd64"
export CHEFDK_PKG="chefdk_$CHEFDK_VERSION.deb"
export CHEFDK_PKG_URL="https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$CHEFDK_PKG"

# GENERAL DEPENDENCIES
apt-get update -y
apt-get upgrade -y
apt-get install -y openjdk-7-jdk git software-properties-common python-software-properties

# WILDFLY INSTALLATION
if [ ! -e $SRC_DIR/$WILDFLY_PKG ]; then
echo ">>>>>>>> Downloading WildFly $WILDFLY_VERSION..."
wget -nv -c $WILDFLY_PKG_URL -O $SRC_DIR/$WILDFLY_PKG
fi
echo ">>>>>>>> Extracting WildFly $WILDFLY_VERSION..."
tar --overwrite -xf $SRC_DIR/$WILDFLY_PKG -C $WILDFLY_DESTDIR
echo ">>>>>>>> Installing WildFly $WILDFLY_VERSION..."
mv $WILDFLY_DESTDIR/$WILDFLY_PKG_DIR $WILDFLY_HOME
adduser --system --group --disabled-login $WILDFLY_USER
chown -R $WILDFLY_USER:$WILDFLY_USER $WILDFLY_HOME
usermod $WILDFLY_USER --home $WILDFLY_HOME
if id -u vagrant > /dev/null 2>&1; then
	addgroup vagrant $WILDFLY_USER
fi
cp $WILDFLY_HOME/bin/init.d/wildfly-init-debian.sh /etc/init.d/$WILDFLY_SERVICE
cp $WILDFLY_HOME/bin/init.d/wildfly.conf /etc/default/$WILDFLY_SERVICE
update-rc.d $WILDFLY_SERVICE defaults
echo "WILDFLY_HOME=\"$WILDFLY_HOME\"" >> /etc/environment
echo "WILDFLY_USER=\"$WILDFLY_USER\"" >> /etc/environment
service $WILDFLY_SERVICE start

# PUPPET INSTALLATION
if [ ! -e $SRC_DIR/$PUPPET_APTPKG ]; then
echo ">>>>>>>> Downloading Puppet APT Package..."
wget -nv -c $PUPPET_APTPKG_URL -O $SRC_DIR/$PUPPET_APTPKG
fi
echo ">>>>>>>> Installing latest Puppet..."
dpkg -i $SRC_DIR/$PUPPET_APTPKG
apt-get -y update
apt-get -y install puppet

# ANSIBLE INSTALLATION
# Sooo easy! Thanks, Ansible guys!
echo ">>>>>>>> Installing latest Ansible..."
apt-add-repository -y ppa:ansible/ansible
apt-get -y update
apt-get install -y ansible

# CHEF INSTALLATION
# Awkward installation is awkward.
if [ ! -e $SRC_DIR/$CHEFDK_PKG ]; then
echo ">>>>>>>> Downloading Chef $CHEFDK_VERSION..."
wget -nv -c $CHEFDK_PKG_URL -O $SRC_DIR/$CHEFDK_PKG
fi
echo ">>>>>>>> Installing Chef $CHEFDK_VERSION..."
dpkg -i $SRC_DIR/$CHEFDK_PKG
