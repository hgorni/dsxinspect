#!/usr/bin/env perl
########################################################################################
# Copyright 2019 Henrique Gorni                                                        #
#                                                                                      #
# Redistribution and use in source and binary forms, with or without modification,     #
# are permitted provided that the following conditions are met:                        #
#                                                                                      #
# 1. Redistributions of source code must retain the above copyright notice, this       #
# list of conditions and the following disclaimer.                                     #
#                                                                                      #
# 2. Redistributions in binary form must reproduce the above copyright notice, this    #
# list of conditions and the following disclaimer in the documentation and/or other    #
# materials provided with the distribution.                                            #
#                                                                                      #
# 3. Neither the name of the copyright holder nor the names of its contributors may    #
# be used to endorse or promote products derived from this software without specific   #
# prior written permission.                                                            #
#                                                                                      #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY  #
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES # 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT  #
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,       #
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED # 
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR   #
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     #
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN   #
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  #
# DAMAGE.                                                                              #
########################################################################################

use strict;
use Getopt::Long qw(GetOptions);
use File::Spec;
use Time::HiRes qw/gettimeofday/;

# Parameters
my $path_dsx; 
my $term_qry;
my $case_sens;
my $out_dir;

GetOptions('f=s' => \$path_dsx, 
           'q=s' => \$term_qry, 
           'c'   => \$case_sens,
           'o=s' => \$out_dir); 

my $s_help =  "Usage: $0 -f <file> -q <term> -c -o <file>\n" .
              "Where:\n" .
              "-f path to dsx file\n" .
              "-q term to be searched (can be a regular expression)\n" .
              "-c (optional) case sensitive search\n" .
              "-o (optional) dir to output the dsx of the jobs where the term was found\n";

(print $s_help and exit 255) unless ($path_dsx and $term_qry);

# Open dsx file to begin search
open my $fr, '<', $path_dsx or die "Unable to open file $path_dsx. $!\n";

my $curr_job = undef;
my $curr_line = -1;
my $next_line_dsid = undef;
my @lines = ();

print "Searching for term <$term_qry> in file <$path_dsx> ...\n";
while (<$fr>) {
    # When beginning of job definition is found flag that the next line contains the Job name
    if(/BEGIN DSJOB/){
        $next_line_dsid = 1;
    }elsif($next_line_dsid){
        # Get job name
        $next_line_dsid = undef;
        /Identifier \"([^"]+)\"/;
        $curr_job = $1;
    }elsif($curr_job){
        # Begin pattern search once end of Job definition is found
        if(/END DSJOB/){
            push @lines, $_;
            my $job_def = join '', @lines;

            my $found = undef;
            if($case_sens){
                $found = $job_def =~ m/$term_qry/;
            }else{
                $found = $job_def =~ m/$term_qry/i; 
            }

            # If term is found in dsx, write to output informing 
            if($found){
                print "Term found in: " . $curr_job . "\n";

                # If -o option is informed, write the current job to a .dsx file
                if($out_dir){
                    my $ctime = gettimeofday;
                    my $out_dsx = File::Spec->catfile($out_dir, $curr_job . '_' . $ctime . '.dsx');
                    open my $fo, '>', $out_dsx or die "Unable to write to file $out_dsx. $!\n";
                    print $fo $job_def;
                    close $fo;
                }
            }

            @lines = ();
            $curr_job = undef;
        }else{
            # Buffer job definition 
            push @lines, $_; 
        }
    }
}

close $fr;
