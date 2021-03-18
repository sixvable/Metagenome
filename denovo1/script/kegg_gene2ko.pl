#!/usr/bin/perl -w
# 加载时间管理，参数管理，文件名和路径处理的基础包，无须安装
use POSIX qw(strftime);
use Getopt::Std;
use File::Basename;

###############################################################################
#Scripts usage and about.
# 程序的帮助文档，良好的描述是程序重用和共享的基础，也是程序升级和更新的前提
###############################################################################
sub usage {
    die(
        qq!
Usage:    kegg_gene2ko.pl -i ko_genes.list -o gene2ko.txt
Function: Format kegg KO to gene list into gene 2 KOs.
Command:  -i inpute file name (Must)
          -o output file name (Must)
          -d database file name
          -h header line number, default 0
Author:   Liu Yong-Xin, liuyongxin_bio\@163.com, QQ:42789409
Version:  v1.0
Update:   2021/1/9
Notes:    
\n!
    )
}

###############################################################################
#命令行参数据的定义和获取，记录程序初始时间，设置参数默认值
#Get the parameter and provide the usage.
###############################################################################
my %opts;
getopts( 'i:o:d:h:', \%opts );
&usage unless ( exists $opts{i} && exists $opts{o} );
my $start_time=time;
print strftime("Start time is %Y-%m-%d %H:%M:%S\n", localtime(time));
print "Input file is $opts{i}\nOutput file is $opts{o}\n";
print "Database file is $opts{d}\n" if defined($opts{d});
# 调置参数的初始值，可以添加更多参数的默认值
$opts{h}=0 unless defined($opts{h});

###############################################################################
#读入的数据或注释文件，用于与输入文件比较或注释(可选)，提供三种方式
#Read the database in memory(opt)
###############################################################################
#open DATABASE,"<$opts{d}";
# 1. 散列结构数据库，要求数据文件有唯一ID并且无顺序要求
#my %database; #database in hash
#while (<DATABASE>) {
#	chomp;
#	my @tmp=split/\t/;
#	$database{$tmp[1]}=$tmp[2];
#}
# 2. 数组结构数据库，无唯一ID，但有顺序要求
#my (@tmp1,@tmp2); #database in array
#while (<DATABASE>) {
#	chomp;
#	my @tmp=split/\t/;
#	push @tmp1,$tmp[1];
#	push @tmp2,@tmp[2];
#}
#close DATABASE;
# 3. 批量数据文件，读取一批有相似结构的文件
#open a list file
#my %list;
#my @filelist=glob "$opts{i}";
#foreach $file(@filelist){
#	open DATABASE,"<$file";
#	$file=basename($file);
#	while (<DATABASE>) {
#		my @tmp=split/\t/;
#		$list{$file}{nr}++;
#	}
#	close DATABASE;
#}

###############################################################################
#Main text.
###############################################################################
# 正文部分，读取输入文件，列出输入和输入文件的三行作为示例，方便编程处理数据
open INPUT,"<$opts{i}";
#ko:K14021       hsa:578
#ko:K14018       hsa:9373
#ko:K04429       hsa:9344
open OUTPUT,">$opts{o}";
#KgeneID	KO
#hsa:578	K14021
#hsa:9373	K14018
#hsa:9344	K14021,K14021

#my %count;
## h参数用于去除有文件头的行
#while ($opts{h}>0) { #filter header
#	$tmp=<INPUT>;
#	$opts{h}--;
#	# 可选，输出文件也保留文件头
#	#print OUTPUT $tmp;
#}
# 输入和输入处理部分，常用按行读取处理并输入，默认按tab分割数据

# 使用存储结果，防止输出重复结果
my %database;
print OUTPUT "KgeneID\tKO\n";
while (<INPUT>) {
	chomp;
	my @tmp=split/\t/;
	$tmp[0]=~s/ko://;
	if ($database{$tmp[1]}) {
		$database{$tmp[1]}.=",$tmp[0]";
#		print $database{$tmp[1]},"\n";
	}else{
		$database{$tmp[1]}=$tmp[0];
	}
}
close INPUT;

foreach my $id (keys %database){
	print OUTPUT "$id\t$database{$id}\n";
}


close OUTPUT;

###############################################################################
#Record the program running time!
# 输出程序运行时间
###############################################################################
my $duration_time=time-$start_time;
print strftime("End time is %Y-%m-%d %H:%M:%S\n", localtime(time));
print "This compute totally consumed $duration_time s\.\n";

