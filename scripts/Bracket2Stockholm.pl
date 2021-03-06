#!/usr/local/bin/perl

opendir(DIR, ".");
my @Files = readdir(DIR);



foreach my $InFile (@Files) {

	if ($InFile =~ m/.aln/) {
                open (ALN, $InFile) || die "Can't open alignment!\n";
                my @ALN = <ALN>;
                close ALN;
                
                #Get locus name
                my @FileName = split(/\./,$InFile);
                my $LocusName = $FileName[0];
                
                print "Creating sto file for $LocusName\n";
				
                #Open Outfile and print stockholm header
                my $OutFile = "$LocusName" . ".sto";
                open (OUT, ">$OutFile");
                print OUT "# STOCKHOLM 1.0\n\n";

                #Grab Hash with seqs and names
                my %ParsedALN = ParseClustal (@ALN);
                
                #Open alifold output, get structure, convert ( ) to < > and
                #print out in Stockholm format
                my $RNAstructureOUT =  "$LocusName" . ".bt";
                open (RNA, "$RNAstructureOUT");
                my @RNA = <RNA>;
                my $STR = ParseRNAstructure (@RNA);

                #Now print seq in blocks of 50 characters to fit in with the
                #Stockholm format requirements for correct parsing by infernal
                
                for (my $i = 0; $i < length($STR); $i += 50) {
                        while ( my ($key, $value) = each(%ParsedALN) ) {
                        my $SeqFrag = substr($value, $i, 50);
                        print OUT "$key\t\t$SeqFrag\n";
                        }
                        my $STRFrag = substr($STR, $i, 50);
                        print OUT "#=GC SS_cons\t\t$STRFrag\n\n";

                }
                #Print the stockholm "footer"
                print OUT '//';
                
                close OUT;

	}
}



################################################################################

sub ParseClustal {

my @ALN = @_;
my $Len = @ALN;
my %OutHash = ();

#Begin at i=3 because of Clustal header
for (my $i = 3; $i < $Len; $i++) {

        my $Line = $ALN[$i];
        chomp $Line;
        
        if ($Line =~ m/A|G|C|U|T|a|g|c|u|t|-|R|N|W|Y|K/) {
                my @Split = split(/\s+/,$Line);
                my $Name = $Split[0];
                my $Seq = $Split[1];
                $OutHash{$Name} .= $Seq;
                }
        }
return (%OutHash);
}

################################################################################

sub ParseRNAstructure {

my @ALI = @_;
my $STR = $ALI[2];
chomp $STR;

$STR =~ s/\)/>/g;
$STR =~ s/\(/</g;

return $STR;

}
        

