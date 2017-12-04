#sudo docker build -t centos7-sshd .
#sudo docker run --name centos7   -d   centos7-sshd:latest
From centos:latest
MAINTAINER Linc "13579443@qq.com"
RUN TERM=linux && export TERM
USER root 
#阿里云yum源
RUN  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
#常用软件安装 && 清除YUM缓存目录(/var/cache/yum)下的软件包及旧的headers
RUN  yum -y install  openssl openssl-devel lrzsz vim unzip net-tools iproute bind-utils  telnet   openssh-server openssh-clients crontabs supervisor &&   yum -y install epel-release && yum --enablerepo=epel install -y supervisor&& yum clean all && rm -rf /tmp/yum*
 
#sshd服务 
RUN  echo "root:b8b288f7f519f8bed62714d073fef49a" | chpasswd ; \
      rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key ; \
      ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key  ; \
      ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key ; \ 
      ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key ; \ 
	  sed -ri "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config ; \
      sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config ; \
      sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config ; \
      sed -ri 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config ; \
      sed -ri 's/#ClientAliveInterval 0/ClientAliveInterval 600/g' /etc/ssh/sshd_config ; \
      sed -ri 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config ;   
ADD container-files /  
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"] 

