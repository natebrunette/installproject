NameVirtualHost *:80

<VirtualHost *:80>
    DocumentRoot @DOCUMENT_ROOT@

    ServerName @SERVER_NAME@.dev
    ServerAlias www.@SERVER_NAME@.dev

    ErrorLog "logs/@SERVER_NAME@.dev-error_log"
    CustomLog "logs/@SERVER_NAME@.dev-access_log" common
</VirtualHost>
