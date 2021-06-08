download() 
{
  curl https://downloads.apache.org//apr/apr-util-1.6.1.tar.gz -O
  curl https://downloads.apache.org//apr/apr-1.7.0.tar.gz -O
  curl https://downloads.apache.org//httpd/httpd-2.4.46.tar.gz -O 
}

packages()
{
 sudo  dnf -y install apr-util.x86_64 pcre-devel git perl m4 autoconf automake libtool make patch openssl openssl-devel
}

extract()
{
tar xvf  httpd-2.4.46.tar.gz
cd httpd-2.4.46/srclib
tar xvf ../../apr-util-1.6.1.tar.gz
mv apr-util-1.6.1 apr-util
tar xvf ../../apr-1.7.0.tar.gz
mv apr-1.7.0 apr
cd ../../
}

apacheconfig()
{
	cd httpd-2.4.46
	./configure --prefix=apache_installation_directory \
             --with-mpm=worker \
             --enable-mods-shared=most \
             --enable-maintainer-mode \
             --enable-ssl \
             --enable-proxy \
             --enable-proxy-http \
             --enable-proxy-ajp \
             --disable-proxy-balancer \
	     --enable-so \
	     --enable-mods-shared=all  --with-included-apr --prefix=/httpd
	cd -
}

build()
{
	cd httpd-2.4.46
	make 
	cd -
}

install(){
	cd httpd-2.4.46
	export DESTDIR=/tmp/apache/
	make -e  install
	cd -
}
clone_mod_cluster()
{


	git clone https://github.com/modcluster/mod_cluster.git
	cd mod_cluster
	git checkout 1.3.1.Final
       	mvn package -Dmaven.compiler.target=1.8

}

build_modules()
{
	InstallDir=/tmp/apache/
	cd mod_cluster/native
        for p in advertise mod_manager mod_proxy_cluster mod_cluster_slotmem
        do
                cd $p
                        ./buildconf
                        CFLAGS=-Wno-error ./configure --with-apxs=$InstallDir/httpd/bin/apxs
			make CFLAGS="-Wno-error"
                        cp $p.so $InstallDir/httpd/modules/

                cd -
        done


}
package()
{
	cd $InstallDir
	tar zcvf httpd.tar.gz httpd
	cd -
	mkdir build ;cp $InstallDir/httpd.tar.gz build/
}
ARGS=$1
InstallDir=${2:-/tmp/apache/}
case "$ARGS" in 
"download")
		download
;;
"packages")
		packages
;;
"extract")
		extract	
;;
"apacheconfig")
		apacheconfig	
;;
"build")
		build	
;;
"install")
		install	
;;
"clone_mod_cluster")
		clone_mod_cluster
;;
"build_modules")
		build_modules
;;
"package")
		package
;;
"all")
	download
	packages
	extract
	apacheconfig
	build
	install
	clone_mod_cluster
	build_modules
;;
esac
