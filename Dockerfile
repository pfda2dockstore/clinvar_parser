# Generated by precisionFDA exporter (v1.0.3) on 2018-06-14 03:33:49 +0000
# The asset download links in this file are valid only for 24h.

# Exported app: clinvar_parser, revision: 4, authored by: arturo.pineda
# https://precision.fda.gov/apps/app-Bxp6VKQ0833qYb0J858vy6bj

# For more information please consult the app export section in the precisionFDA docs

# Start with Ubuntu 14.04 base image
FROM ubuntu:14.04

# Install default precisionFDA Ubuntu packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
	aria2 \
	byobu \
	cmake \
	cpanminus \
	curl \
	dstat \
	g++ \
	git \
	htop \
	libboost-all-dev \
	libcurl4-openssl-dev \
	libncurses5-dev \
	make \
	perl \
	pypy \
	python-dev \
	python-pip \
	r-base \
	ruby1.9.3 \
	wget \
	xz-utils

# Install default precisionFDA python packages
RUN pip install \
	requests==2.5.0 \
	futures==2.2.0 \
	setuptools==10.2

# Add DNAnexus repo to apt-get
RUN /bin/bash -c "echo 'deb http://dnanexus-apt-prod.s3.amazonaws.com/ubuntu trusty/amd64/' > /etc/apt/sources.list.d/dnanexus.list"
RUN /bin/bash -c "echo 'deb http://dnanexus-apt-prod.s3.amazonaws.com/ubuntu trusty/all/' >> /etc/apt/sources.list.d/dnanexus.list"
RUN curl https://wiki.dnanexus.com/images/files/ubuntu-signing-key.gpg | apt-key add -

# Update apt-get
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Download helper executables
RUN curl https://dl.dnanex.us/F/D/0K8P4zZvjq9vQ6qV0b6QqY1z2zvfZ0QKQP4gjBXp/emit-1.0.tar.gz | tar xzf - -C /usr/bin/ --no-same-owner --no-same-permissions
RUN curl https://dl.dnanex.us/F/D/bByKQvv1F7BFP3xXPgYXZPZjkXj9V684VPz8gb7p/run-1.2.tar.gz | tar xzf - -C /usr/bin/ --no-same-owner --no-same-permissions

# Write app spec and code to root folder
RUN ["/bin/bash","-c","echo -E \\{\\\"spec\\\":\\{\\\"input_spec\\\":\\[\\{\\\"name\\\":\\\"clinvar_file\\\",\\\"class\\\":\\\"file\\\",\\\"optional\\\":false,\\\"label\\\":\\\"Clinvar\\ file\\ \\(.txt\\)\\\",\\\"help\\\":\\\"A\\ .txt\\ file\\ from\\ the\\ Clinvar\\ website\\\",\\\"default\\\":\\\"file-Bxjy0jj01xZ1KpZP1kkpf65Q\\\"\\},\\{\\\"name\\\":\\\"goi_list\\\",\\\"class\\\":\\\"file\\\",\\\"optional\\\":false,\\\"label\\\":\\\"GoI\\ list\\ file\\ \\(.txt\\)\\\",\\\"help\\\":\\\"A\\ .txt\\ file\\ containing\\ a\\ list\\ of\\ genes\\ of\\ interest\\ \\(gene\\ name,\\ chromosome,\\ start\\ and\\ stop\\ positions\\)\\\",\\\"default\\\":\\\"file-BxkFXg00q5pyYFFgk1G5x2j8\\\"\\},\\{\\\"name\\\":\\\"clinical_significance\\\",\\\"class\\\":\\\"string\\\",\\\"optional\\\":false,\\\"label\\\":\\\"Clinical\\ Significance\\\",\\\"help\\\":\\\"Choose\\ between\\ three\\ options\\\",\\\"default\\\":\\\"Pathogenic\\\",\\\"choices\\\":\\[\\\"Pathogenic\\\",\\\"Likely\\ pathogenic\\\",\\\"Benign\\\",\\\"Likely\\ benign\\\"\\]\\}\\],\\\"output_spec\\\":\\[\\{\\\"name\\\":\\\"clinvar_filtered\\\",\\\"class\\\":\\\"file\\\",\\\"optional\\\":false,\\\"label\\\":\\\"Clinvar\\ tab\\ delimited\\ file\\\",\\\"help\\\":\\\"\\\"\\}\\],\\\"internet_access\\\":false,\\\"instance_type\\\":\\\"baseline-8\\\"\\},\\\"assets\\\":\\[\\],\\\"packages\\\":\\[\\]\\} \u003e /spec.json"]
RUN ["/bin/bash","-c","echo -E \\{\\\"code\\\":\\\"\\#----------------------------------------------\\\\n\\#\\\\n\\#\\ Project:\\ GoI\\ Diversity\\\\n\\#\\ Author:\\ Arturo\\ Lopez\\ Pineda\\ \\\\u003carturolp@stanford.edu\\\\u003e\\\\n\\#\\ Date:\\ June\\ 29,\\ 2016\\\\n\\#\\\\n\\#----------------------------------------------\\\\n\\\\n\\\\nclinical_significance\\=\\\\\\\"\\$clinical_significance\\\\\\\"\\\\nreview_status\\=\\\\\\\"reviewed\\ by\\ expert\\ panel\\\\\\\"\\\\n\\\\n\\#Header\\\\nawk\\ -F\\ \\'\\\\\\\\t\\'\\ \\'\\(NF\\=\\=29\\ \\\\u0026\\\\u0026\\ NR\\=\\=1\\)\\ \\{printf\\ \\$1\\\\\\\"\\\\\\\\t\\\\\\\"\\$5\\\\\\\"\\\\\\\\t\\\\\\\"\\$14\\\\\\\"\\\\\\\\t\\\\\\\"\\$15\\\\\\\"\\\\\\\\t\\\\\\\"\\$16\\\\\\\"\\\\\\\\t\\\\\\\"\\;\\ printf\\ \\\\\\\"\\\\\\\\n\\\\\\\"\\;\\}\\'\\ \\\\\\\"\\$clinvar_file_path\\\\\\\"\\ \\\\u003e\\ clinvar_tab.txt\\\\n\\\\n\\\\n\\#awk\\ -F\\ \\'\\\\\\\\t\\'\\ \\ -v\\ h\\=0\\ \\'\\(NF\\=\\=8\\ \\\\u0026\\\\u0026\\ h\\=\\=0\\ \\\\u0026\\\\u0026\\ index\\(\\$0,\\\\\\\"\\#\\\\\\\"\\)\\=\\=0\\)\\ \\{printf\\ \\\\\\\"\\#CHROM\\\\\\\\tPOS\\\\\\\\tREF\\\\\\\\tALT\\\\\\\\t\\\\\\\"\\ \\;\\ split\\(\\$8,a,\\\\\\\"\\;\\\\\\\"\\)\\;\\ for\\(i\\=1\\;i\\\\u003c\\=length\\(a\\)\\;i\\+\\+\\)\\ \\{split\\(a\\[i\\],b,\\\\\\\"\\=\\\\\\\"\\)\\;\\ if\\(b\\[1\\]\\=\\=\\\\\\\"AF\\\\\\\"\\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC\\\\\\\"\\ \\ \\|\\|\\ \\ b\\[1\\]\\=\\=\\\\\\\"AC_AMR\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_AMR\\\\\\\"\\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC_FIN\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_FIN\\\\\\\"\\ \\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC_NFE\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_NFE\\\\\\\"\\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC_SAS\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_SAS\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC_EAS\\\\\\\"\\ \\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_EAS\\\\\\\"\\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AC_AFR\\\\\\\"\\ \\|\\|\\ b\\[1\\]\\=\\=\\\\\\\"AN_AFR\\\\\\\"\\)\\ printf\\ b\\[1\\]\\\\\\\"\\\\\\\\t\\\\\\\"\\;\\}\\ printf\\ \\\\\\\"\\\\\\\\n\\\\\\\"\\;\\ h\\=1\\}\\'\\ exac-small.txt\\ \\\\u003e\\ exac-tab.txt\\\\n\\\\n\\\\n\\\\n\\{\\\\n\\\\tread\\\\n\\\\twhile\\ IFS\\=\\$\\'\\\\\\\\t\\'\\ read\\ -r\\ geneID\\ chromosome\\ startPosition\\ endPosition\\ \\|\\|\\ \\[\\[\\ -n\\ \\\\\\\"\\$geneID\\\\\\\"\\ \\]\\]\\\\n\\\\tdo\\ \\\\n\\\\techo\\ \\\\\\\"Gene\\ \\$geneID\\ is\\ in\\ chromosome\\ \\$chromosome\\ and\\ starts\\ at\\ \\$startPosition\\ and\\ ends\\ at\\ \\$endPosition\\\\\\\"\\\\n\\\\tawk\\ -F\\ \\'\\\\\\\\t\\'\\ -v\\ g\\=\\\\\\\"\\$geneID\\\\\\\"\\ -v\\ cs\\=\\\\\\\"\\$clinical_significance\\\\\\\"\\ -v\\ re\\=\\\\\\\"\\$review_status\\\\\\\"\\ \\'\\(NF\\=\\=29\\ \\\\u0026\\\\u0026\\ \\$5\\=\\=g\\ \\\\u0026\\\\u0026\\ \\$6\\=\\=cs\\ \\\\u0026\\\\u0026\\ \\$18\\=\\=re\\)\\ \\{printf\\ \\$1\\\\\\\"\\\\\\\\t\\\\\\\"\\$5\\\\\\\"\\\\\\\\t\\\\\\\"\\$14\\\\\\\"\\\\\\\\t\\\\\\\"\\$15\\\\\\\"\\\\\\\\t\\\\\\\"\\$16\\;\\ printf\\ \\\\\\\"\\\\\\\\n\\\\\\\"\\;\\}\\'\\ \\\\\\\"\\$clinvar_file_path\\\\\\\"\\ \\\\u003e\\\\u003e\\ clinvar_tab.txt\\\\n\\\\tdone\\\\n\\\\t\\}\\ \\\\u003c\\ \\\\\\\"\\$goi_list_path\\\\\\\"\\\\n\\\\nemit\\ clinvar_filtered\\ clinvar_tab.txt\\\"\\} | python -c 'import sys,json; print json.load(sys.stdin)[\"code\"]' \u003e /script.sh"]

# Create directory /work and set it to $HOME and CWD
RUN mkdir -p /work
ENV HOME="/work"
WORKDIR /work

# Set entry point to container
ENTRYPOINT ["/usr/bin/run"]

VOLUME /data
VOLUME /work