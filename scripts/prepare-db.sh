export MYDATE="$(date +%d%m)-"
export MYDATE=""
export VERSION=$1
export DATABASES=$2
export WO_DEMO=$3
export CONTAINER="$(docker ps -f name=${1}_odoo_run --format {{.Names}})"
export ODOO_SEVER="odoo"


if [ -z "$VERSION" ]; then
  echo "Missing info odoo version: prepare.sh VERSION databases. example sh prepare.sh 13 ar"
  exit
elif [ -z "$DATABASES" ]; then
  echo "Missing info of version: prepare.sh version DATABASES. example sh prepare.sh 13 ar"
  exit
elif [ -z "$CONTAINER" ]; then
  echo "There is not running container for the given version"
  exit
fi

echo "This will applied in container $CONTAINER"

create_db_install () {
    if [ -z "$WO_DEMO" ]; then
        EXTRA_PARAMS=""
        DB_NAME="$VERSION-$MYDATE$1"
    else
        EXTRA_PARAMS="--without-demo=all"
        DB_NAME="$VERSION-$MYDATE$1_wo_demo"
    fi

    echo "Prepare $DB_NAME database"
    docker exec -it $CONTAINER dropdb --if-exists $DB_NAME
    docker exec -it $CONTAINER createdb $DB_NAME
    docker exec -it $CONTAINER $ODOO_SEVER -d $DB_NAME -i $2 --stop-after-init $EXTRA_PARAMS
    echo "Database $DB_NAME is ready!"
}

create_db_from_install () {

    if [ -z "$WO_DEMO" ]; then
        EXTRA_PARAMS=""
        DB_NAME="$VERSION-$MYDATE$1"
        TDB_NAME="$VERSION-$MYDATE$2"
    else
        EXTRA_PARAMS="--without-demo=all"
        DB_NAME="$VERSION-$MYDATE$1_wo_demo"
        TDB_NAME="$VERSION-$MYDATE$2_wo_demo"
    fi

    echo "Prepare $DB_NAME database"
    docker exec -it $CONTAINER dropdb --if-exists $DB_NAME
    docker exec -it $CONTAINER createdb $DB_NAME -T $TDB_NAME
    docker exec -it $CONTAINER $ODOO_SEVER -d $DB_NAME -i $3 --stop-after-init $EXTRA_PARAMS

    echo "Database $DB_NAME is ready!"
}

create_db_from_install_translation () {
    echo "Prepare $1 database"
    docker exec -it $CONTAINER dropdb --if-exists $MYDATE$1
    docker exec -it $CONTAINER createdb $MYDATE$1 -T $MYDATE$2
    docker exec -it $CONTAINER $ODOO_SEVER -d $MYDATE$1 -i $3 --stop-after-init
    echo "Database $MYDATE$1 is ready!"
}

create_db_from () {
    echo "Prepare $1 database"
    docker exec -it $CONTAINER dropdb --if-exists $MYDATE$1
    docker exec -it $CONTAINER createdb $MYDATE$1 -T $MYDATE$2
    docker exec -it $CONTAINER $ODOO_SEVER -d $MYDATE$1 --stop-after-init
    echo "Database $MYDATE$1 is ready!"
}

if [ $DATABASES = "base" ]; then
    create_db_install "base" "base"
elif [ $DATABASES = "account" ]; then
    create_db_from_install "account" "base" "account_accountant"
elif [ $DATABASES = "latam" ]; then
    create_db_from_install "latam" "account" "l10n_latam_invoice_document,l10n_latam_base"
elif [ $DATABASES = "ar" ]; then
    create_db_from_install "ar" "latam" "l10n_ar"
elif [ $DATABASES = "ar_all" ]; then
    create_db_from_install "ar" "base" "l10n_ar"
elif [ $DATABASES = "report" ]; then
    create_db_from_install "report" "ar" "l10n_ar_reports"
elif [ $DATABASES = "ar-edi" ]; then
    create_db_from_install "ar-edi" "ar" "l10n_ar_edi"
elif [ $DATABASES = "website" ]; then
    create_db_from_install "website" "edi" "website_sale"
elif [ $DATABASES = "website_ar" ]; then
    create_db_from_install "website_ar" "website" "l10n_ar_website_sale"
elif [ $DATABASES = "test" ]; then
    create_db_from "test" "account"

elif [ $DATABASES = "uy" ]; then
    create_db_from_install "uy" "latam" "l10n_uy"

elif [ $DATABASES = "translation" ]; then
    create_db_from_install_translation "translation" "ar-edi" "i18n_helper" "--load-language=es_ES"
    # create_db_from_install_translation "translation" "ar-edi" "l10n_ar,l10n_ar_reports,i18n_helper" "--load-language=es_ES"
elif [ $DATABASES = "last" ]; then
    create_db_from_install "latam" "account" "l10n_latam_invoice_document,l10n_latam_base"
    create_db_from_install "ar" "latam" "l10n_ar"
    create_db_from_install "ar-edi" "ar" "l10n_ar_edi"
elif [ $DATABASES = "all" ]; then
    create_db_install "base" "base"
    create_db_from_install "account" "base" "account_accountant"
    create_db_from_install "latam" "account" "l10n_latam_invoice_document,l10n_latam_base"
    create_db_from_install "ar" "latam" "l10n_ar"
    create_db_from_install "ar-edi" "ar" "l10n_ar_edi"
    # create_db_from_install "report" "ar" "l10n_ar_reports"
    # create_db_from "test" "ar-edi"
    # create_db_from_install_translation "translation" "ar-edi" "i18n_helper" "--load-language=es_ES"
else
  echo "try again"
fi