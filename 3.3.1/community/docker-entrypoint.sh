#!/bin/bash -eu

cmd="$1"

if [[ "${cmd}" != *"neo4j"* ]]; then
    [ -f "${EXTENSION_SCRIPT:-}" ] && . ${EXTENSION_SCRIPT}

    if [ "${cmd}" == "dump-config" ]; then
        if [ -d /conf ]; then
            cp --recursive conf/* /conf
            exit 0
        else
            echo "You must provide a /conf volume"
            exit 1
        fi
    fi
    exec "$@"
    exit $?
fi

if [ "$NEO4J_EDITION" == "enterprise" ]; then
    if [ "${NEO4J_ACCEPT_LICENSE_AGREEMENT:=no}" != "yes" ]; then
        echo "
In order to use Neo4j Enterprise Edition you must accept the license agreement.

(c) Network Engine for Objects in Lund AB.  2017.  All Rights Reserved.
Use of this Software without a proper commercial license with Neo4j,
Inc. or its affiliates is prohibited.

Email inquiries can be directed to: licensing@neo4j.com

More information is also available at: https://neo4j.com/licensing/


To accept the license agreemnt set the environment variable
NEO4J_ACCEPT_LICENSE_AGREEMENT=yes

To do this you can use the following docker argument:

        --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
"
        exit 1
    fi
fi

# Env variable naming convention:
# - prefix NEO4J_
# - double underscore char '__' instead of single underscore '_' char in the setting name
# - underscore char '_' instead of dot '.' char in the setting name
# Example:
# NEO4J_dbms_tx__log_rotation_retention__policy env variable to set
#       dbms.tx_log.rotation.retention_policy setting

# Backward compatibility - map old hardcoded env variables into new naming convention (if they aren't set already)
# Set some to default values if unset
: ${NEO4J_dbms_tx__log_rotation_retention__policy:=${NEO4J_dbms_txLog_rotation_retentionPolicy:-"100M size"}}
: ${NEO4J_wrapper_java_additional:=${NEO4J_UDC_SOURCE:-"-Dneo4j.ext.udc.source=docker"}}
: ${NEO4J_dbms_memory_heap_initial__size:=${NEO4J_dbms_memory_heap_maxSize:-"512M"}}
: ${NEO4J_dbms_memory_heap_max__size:=${NEO4J_dbms_memory_heap_maxSize:-"512M"}}
: ${NEO4J_dbms_unmanaged__extension__classes:=${NEO4J_dbms_unmanagedExtensionClasses:-}}
: ${NEO4J_dbms_allow__format__migration:=${NEO4J_dbms_allowFormatMigration:-}}
: ${NEO4J_dbms_connectors_default__advertised__address:=${NEO4J_dbms_connectors_defaultAdvertisedAddress:-}}
: ${NEO4J_ha_server__id:=${NEO4J_ha_serverId:-}}
: ${NEO4J_ha_initial__hosts:=${NEO4J_ha_initialHosts:-}}
: ${NEO4J_causal__clustering_expected__core__cluster__size:=${NEO4J_causalClustering_expectedCoreClusterSize:-}}
: ${NEO4J_causal__clustering_initial__discovery__members:=${NEO4J_causalClustering_initialDiscoveryMembers:-}}
: ${NEO4J_causal__clustering_discovery__listen__address:=${NEO4J_causalClustering_discoveryListenAddress:-"0.0.0.0:5000"}}
: ${NEO4J_causal__clustering_discovery__advertised__address:=${NEO4J_causalClustering_discoveryAdvertisedAddress:-"$(hostname):5000"}}
: ${NEO4J_causal__clustering_transaction__listen__address:=${NEO4J_causalClustering_transactionListenAddress:-"0.0.0.0:6000"}}
: ${NEO4J_causal__clustering_transaction__advertised__address:=${NEO4J_causalClustering_transactionAdvertisedAddress:-"$(hostname):6000"}}
: ${NEO4J_causal__clustering_raft__listen__address:=${NEO4J_causalClustering_raftListenAddress:-"0.0.0.0:7000"}}
: ${NEO4J_causal__clustering_raft__advertised__address:=${NEO4J_causalClustering_raftAdvertisedAddress:-"$(hostname):7000"}}

: ${NEO4J_dbms_connectors_default__listen__address:="0.0.0.0"}
: ${NEO4J_dbms_connector_http_listen__address:="0.0.0.0:7474"}
: ${NEO4J_dbms_connector_https_listen__address:="0.0.0.0:7473"}
: ${NEO4J_dbms_connector_bolt_listen__address:="0.0.0.0:7687"}
: ${NEO4J_ha_host_coordination:="$(hostname):5001"}
: ${NEO4J_ha_host_data:="$(hostname):6001"}
: ${NEO4J_dbms_security_auth__enabled:="false"}
: ${NEO4J_dbms_connector_bolt_advertised__address:="$(hostname):7687"}
: ${NEO4J_dbms_active__database:="graph.db"}
: ${NEO4J_dbms_security_procedures_unrestricted:="apoc.*,algo.*,ga.*"}
: ${NEO4J_dbms_security_procedures_whitelist:="apoc.*,algo.*,ga.*"}
: ${NEO4J_apoc_export_file_enabled:="true"}


#: ${NEO4J_dbms_security_auth__enabled:="false"}
#: ${NEO4J_dbms_connector_bolt_advertised__address:="$(hostname):7687"}
#: ${NEO4J_dbms_active__database:="graph.db"}

#: ${NEO4J_dbms_directories_import:="import"}
#: ${NEO4J_dbms_security_allow__csv__import__from__file__urls:="true"}
#: ${NEO4J_dbms_allow__upgrade:="true"}

#: ${NEO4J_dbms_security_procedures_unrestricted:="apoc.*,algo.*,ga.*"}
#: ${NEO4J_dbms_security_procedures_whitelist:="apoc.*,algo.*,ga.*"}
#: ${NEO4J_apoc_export_file_enabled:="true"}

#: ${NEO4J_com_graphaware_runtime_enabled:="true"}
#: ${NEO4J_com_graphaware_module_ES_1:="com.graphaware.module.es.ElasticSearchModuleBootstrapper"}
#: ${NEO4J_com_graphaware_module_ES_uri:="127-0-0-1"}
#: ${NEO4J_com_graphaware_module_ES_port:="9200"}
#: ${NEO4J_com_graphaware_module_ES_mapping:="AdvancedMapping"}
#: ${NEO4J_com_graphaware_module_ES_keyProperty:="ID()"}
#: ${NEO4J_com_graphaware_module_ES_retryOnError:="true"}
#: ${NEO4J_com_graphaware_module_ES_asyncIndexation:="true"}
#: ${NEO4J_com_graphaware_module_ES_initializeUntil:="2000000000000"}
#  # Set "relationship" to "(false)" to disable relationships (edges) indexation
#  # Disabling relationship indexation is recommended if you have a lot of relationships and don't need to search them_ 
#: ${NEO4J_com_graphaware_module_ES_relationship:="(true)"}
#: ${NEO4J_com_graphaware_runtime_stats_disabled:="true"}
#: ${NEO4J_com_graphaware_server_stats_disabled:="true"}


#  dbms.security.auth_enabled=false
#  dbms.connector.bolt.advertised_address:=$(hostname):7687

#  dbms.active_database=panama.graphdb
#  dbms.directories.import=import
#  dbms.security.allow_csv_import_from_file_urls=true
#  dbms.allow_upgrade=true

#  dbms.security.procedures.unrestricted=apoc.*,algo.*,ga.*
#  dbms.security.procedures.whitelist=apoc.*,algo.*,ga.*
#  apoc.export.file.enabled=true

#  com.graphaware.runtime.enabled=true
#  com.graphaware.module.ES.1=com.graphaware.module.es.ElasticSearchModuleBootstrapper
#  com.graphaware.module.ES.uri=127-0-0-1
#  com.graphaware.module.ES.port=9200
#  com.graphaware.module.ES.mapping=AdvancedMapping
#  com.graphaware.module.ES.keyProperty=ID()
#  com.graphaware.module.ES.retryOnError=true
#  com.graphaware.module.ES.asyncIndexation=true
#  com.graphaware.module.ES.initializeUntil=2000000000000
#  # Set "relationship" to "(false)" to disable relationships (edges) indexation. 
#  # Disabling relationship indexation is recommended if you have a lot of relationships and don't need to search them. 
#  com.graphaware.module.ES.relationship=(true)
#  com.graphaware.runtime.stats.disabled=true
#  com.graphaware.server.stats.disabled=true


# unset old hardcoded unsupported env variables
unset NEO4J_dbms_txLog_rotation_retentionPolicy NEO4J_UDC_SOURCE \
    NEO4J_dbms_memory_heap_maxSize NEO4J_dbms_memory_heap_maxSize \
    NEO4J_dbms_unmanagedExtensionClasses NEO4J_dbms_allowFormatMigration \
    NEO4J_dbms_connectors_defaultAdvertisedAddress NEO4J_ha_serverId \
    NEO4J_ha_initialHosts NEO4J_causalClustering_expectedCoreClusterSize \
    NEO4J_causalClustering_initialDiscoveryMembers \
    NEO4J_causalClustering_discoveryListenAddress \
    NEO4J_causalClustering_discoveryAdvertisedAddress \
    NEO4J_causalClustering_transactionListenAddress \
    NEO4J_causalClustering_transactionAdvertisedAddress \
    NEO4J_causalClustering_raftListenAddress \
    NEO4J_causalClustering_raftAdvertisedAddress

# Custom settings for dockerized neo4j
: ${NEO4J_dbms_tx__log_rotation_retention__policy:=100M size}
: ${NEO4J_dbms_memory_pagecache_size:=512M}
: ${NEO4J_wrapper_java_additional:=-Dneo4j.ext.udc.source=docker}
: ${NEO4J_dbms_memory_heap_initial__size:=512M}
: ${NEO4J_dbms_memory_heap_max__size:=512M}
: ${NEO4J_dbms_connectors_default__listen__address:=0.0.0.0}
: ${NEO4J_dbms_connector_http_listen__address:=0.0.0.0:7474}
: ${NEO4J_dbms_connector_https_listen__address:=0.0.0.0:7473}
: ${NEO4J_dbms_connector_bolt_listen__address:=0.0.0.0:7687}
: ${NEO4J_ha_host_coordination:=$(hostname):5001}
: ${NEO4J_ha_host_data:=$(hostname):6001}
: ${NEO4J_causal__clustering_discovery__listen__address:=0.0.0.0:5000}
: ${NEO4J_causal__clustering_discovery__advertised__address:=$(hostname):5000}
: ${NEO4J_causal__clustering_transaction__listen__address:=0.0.0.0:6000}
: ${NEO4J_causal__clustering_transaction__advertised__address:=$(hostname):6000}
: ${NEO4J_causal__clustering_raft__listen__address:=0.0.0.0:7000}
: ${NEO4J_causal__clustering_raft__advertised__address:=$(hostname):7000}

if [ -d /conf ]; then
    find /conf -type f -exec cp {} conf \;
fi

if [ -d /ssl ]; then
    NEO4J_dbms_directories_certificates="/ssl"
fi

if [ -d /plugins ]; then
    NEO4J_dbms_directories_plugins="/plugins"
fi

if [ -d /logs ]; then
    NEO4J_dbms_directories_logs="/logs"
fi

if [ -d /import ]; then
    NEO4J_dbms_directories_import="/import"
fi

if [ -d /metrics ]; then
    NEO4J_dbms_directories_metrics="/metrics"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # DOWNLOAD: MOVIES DB # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


GUSER="https://github.com/PkSM3"
GREPO="neo4j-3.3.1_moviesdb"
GBRANCH="master"
GFILE=$GREPO"-"$GBRANCH".tar.gz"
GURL=$GUSER"/"$GREPO"/archive/"$GBRANCH".tar.gz"
DATA_FILE=$GBRANCH".tar.gz"
DATA_FOLDER="master"

#rm -R "$DATA_FOLDER" $GBRANCH".tar.gz" $GREPO"-"$GBRANCH

echo "Downloading..."
wget "$GURL"
echo "Downloading... OK"
echo "Uncompressing..."
tar -zxvf "$DATA_FILE"
echo "Uncompressing... OK"
echo "Copying files..."
cp -R ./$GREPO"-"$GBRANCH/databases "data/graph.db"
cp -R ./$GREPO"-"$GBRANCH/plugins/* "plugins/"
echo "Copying files... OK"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # DOWNLOAD: PANAMA PAPERS # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# DATA_FILE="panama-papers-mac-2016-06-27.tar.gz"
# if [ ! -f "./$DATA_FILE" ]; then
#   echo "Downloading data"
#   wget "https://cloudfront-files-1.publicintegrity.org/offshoreleaks/neo4j/$DATA_FILE"
# else
#   echo "Not downloading data as file already exists"
# fi

# if [ ! -d "./panama-papers" ]; then
#   tar -zxvf "$DATA_FILE"
# fi

# if [ ! -d "/data/databases/panama.graphdb" ]; then
#   echo "Copying data over to databases directory"
#   cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/databases /data/
# else
#   echo "Skipping copying data over to databases directory as panama.graphdb already exists"
# fi

# echo "Copying config and plugins"
# cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/conf/* conf/
# cp -R ./panama-papers/ICIJ\ Panama\ Papers/panama_data_for_neo4j/plugins/* plugins/

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 



# set the neo4j initial password only if you run the database server
if [ "${cmd}" == "neo4j" ]; then
    if [ "${NEO4J_AUTH:-}" == "none" ]; then
        NEO4J_dbms_security_auth__enabled=false
    elif [[ "${NEO4J_AUTH:-}" == neo4j/* ]]; then
        password="${NEO4J_AUTH#neo4j/}"
        if [ "${password}" == "neo4j" ]; then
            echo "Invalid value for password. It cannot be 'neo4j', which is the default."
            exit 1
        fi
        # Will exit with error if users already exist (and print a message explaining that)
        bin/neo4j-admin set-initial-password "${password}" || true
    elif [ -n "${NEO4J_AUTH:-}" ]; then
        echo "Invalid value for NEO4J_AUTH: '${NEO4J_AUTH}'"
        exit 1
    fi
fi

# list env variables with prefix NEO4J_ and create settings from them
unset NEO4J_AUTH NEO4J_SHA256 NEO4J_TARBALL
for i in $( set | grep ^NEO4J_ | awk -F'=' '{print $1}' | sort -rn ); do
    setting=$(echo ${i} | sed 's|^NEO4J_||' | sed 's|_|.|g' | sed 's|\.\.|_|g')
    value=$(echo ${!i})
    if [[ -n ${value} ]]; then
        if grep -q -F "${setting}=" conf/neo4j.conf; then
            # Remove any lines containing the setting already
            sed --in-place "/${setting}=.*/d" conf/neo4j.conf
        fi
        # Then always append setting to file
        echo "${setting}=${value}" >> conf/neo4j.conf
    fi
done

[ -f "${EXTENSION_SCRIPT:-}" ] && . ${EXTENSION_SCRIPT}

if [ "${cmd}" == "neo4j" ]; then
    exec neo4j console
else
    exec "$@"
fi
