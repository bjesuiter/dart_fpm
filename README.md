# dart_fpm

A dart handler to execute dart scripts over Fast CGI with Apache or Nginx  

**WARNING: Highly experimental!!!**
**This is currently a personal side project, because I want to run dart files behind Nginx like php with php-fpm**

# Example usage

## Dependencies

- A working nginx(standalone) or apache(with fast-cgi module enabled) webserver
- The dart sdk

## Nginx Configuration

For working fcgi passing in Nginx you need to register the dart_fpm handler in nginx config.
Normally, one would add this part to nginx.conf.
But for better structure I created a folder "servers" and added an 
`include servers/*;` at the bottom of the `http` directive.

The following snippet is an example how to include this fact-cgi handler for all files with *.dart.
It has to be placed inside a `server{}` directive.

    # pass DART scripts to FastCGI server listening on 127.0.0.1:9090
    location ~ \.dart$ {
        fastcgi_pass   localhost:9090;
        fastcgi_index  index.dart;
        #fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        include        fastcgi.conf;
    }
    
###NOTE:
My base directory for localhost is located at 
`/usr/local/Cellar/nginx/1.10.1/html`.
The server directive is configured like this: 

    server {
        listen 8080;
        server_name  localhost;
    
        location / {
            root   html/www;
            index  index.html index.htm index.php index.dart;
        }
        
        # insert dart fcgi handler configuration from above here
    }
    
If you try to access `localhost:8080/sample_script.dart` with this configuration, 
Nginx searches for this dart file in `/usr/local/Cellar/nginx/1.10.1/html` instead of 
`/usr/local/Cellar/nginx/1.10.1/html/www`. 
You can fix this by adding another root directive 
inside the location directive for dart fcgi like this: 

    location ~ \.dart$ {
        root html/www;
    }


# Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/bjesuiter/dart_fpm/issues
