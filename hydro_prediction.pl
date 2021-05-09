# print "Choose k: ";
# $k = <STDIN>;
# chomp $k;
# print "\n";

$k1 = 3;
$k2 = 7;
$k3 = 13;
$/="\/\/\n";
$sequence = "";
@tmstart = ();
@tmend = ();

sub calc_hydro{
	my ($ks, $seq) = @_;
	my @hydro = ();
	for($i=$ks; $i<length($seq)-$ks; $i++){   
		$q=0;
		for($j=$i-$ks; $j<=$i+$ks; $j++){    
			$a=substr($seq,$j,1);           
			$p=$hyd{$a};
			$q=$q+$p;  
		}
		$q=$q/(2*$ks+1); 
		$hydro[$i]=$q;
	}
	return @hydro;
}

while (<>){

	while ($_=~/^FT\s{3}TRANSMEM\s+(\d+)\.\.(\d+)/mg){
        push(@tmstart, $1);
        push(@tmend, $2);
    }



	if ($_=~/^SQ\s{3}SEQUENCE\s+(.*?)\;/m){
		$sequence_length_aa = $1;
		$sequence_length_numeric = $sequence_length_aa;
		$sequence_length_numeric =~ s/\D//g;
    }

	while ($_=~/^\s{5}(.*)/mg){
        $sequence = $sequence . $1;
    }

	
    $lines = "0" x $sequence_length_numeric ;
    $length = @tmstart;

    for($k = 0; $k < $length; $k++){
        
        for($i = @tmstart[$k] - 1; $i < @tmend[$k]; $i++){
            substr($lines,$i,1,"1");
        }
    }
}

$sequence=~s/\s//g;

if ($sequence_length_numeric != length($sequence)){
    print "Error in parsing \n";
	exit;
}


%hyd=( R=>'-4.5',
		K=>'-3.9',
		N=>'-3.5',
		D=>'-3.5',
		Q=>'-3.5',
		E=>'-3.5',
		H=>'-3.2',
		P=>'-1.6',
		Y=>'-1.3',
		W=>'-0.9',
		S=>'-0.8',
		T=>'-0.7',
		G=>'-0.4',
		A=>'1.8',
		M=>'1.9',
		C=>'2.5',
		F=>'2.8',
		L=>'3.8',
		V=>'4.2',
		I=>'4.5' );


@hydrovalue1 = calc_hydro($k1, $sequence); 
@hydrovalue2 = calc_hydro($k2, $sequence);
@hydrovalue3 = calc_hydro($k3, $sequence);
@cm1 = (0) x 4;
@cm2 = (0) x 4;
@cm3 = (0) x 4;

for($i=0; $i<length($sequence); $i++){
	$num = $i + 1; 
	$cr1 = substr($sequence, $i, 1);
	$trans = substr($lines, $i, 1);
	if($hydrovalue1[$num] >= 0){
		if($trans == 0){
			$cm1[2] = $cm1[2] + 1;
		}
		else{
			$cm1[0] = $cm1[0] + 1;
		}
		$h1 = 0.9;
		$b1 = 1;
	}
	else{
		if($trans == 0){
			$cm1[1] = $cm1[1] + 1;
		}
		else{
			$cm1[3] = $cm1[3] + 1;
		}
		$h1 = 0.3;
		$b1 = 0;
	}

	if($hydrovalue2[$num] >= 0){
		if($trans == 0){
			$cm2[2] = $cm2[2] + 1;
		}
		else{
			$cm2[0] = $cm2[0] + 1;
		}
		$h2 = 0.8;
		$b2 = 1;
	}
	else{
		if($trans == 0){
			$cm2[1] = $cm2[1] + 1;
		}
		else{
			$cm2[3] = $cm2[3] + 1;
		}
		$h2 = 0.2;
		$b2 = 0;
	}

	if($hydrovalue3[$num] >= 0){
		if($trans == 0){
			$cm3[2] = $cm3[2] + 1;
		}
		else{
			$cm3[0] = $cm3[0] + 1;
		}
		$h3 = 0.7;
		$b3 = 1;
	}
	else{
		if($trans == 0){
			$cm3[1] = $cm3[1] + 1;
		}
		else{
			$cm3[3] = $cm3[3] + 1;
		}
		$h3 = 0.1;
		$b3 = 0;
	}
	print "$num,$cr1,$trans,$h1,$h2,$h3,$b1,$b2,$b3,$hydrovalue1[$num],$hydrovalue2[$num],$hydrovalue3[$num] \n";
} 
# print "True positive: $cm1[0] True negative: $cm1[1] False positive: $cm1[2] False negative: $cm1[3]\n";
# print "True positive: $cm2[0] True negative: $cm2[1] False positive: $cm2[2] False negative: $cm2[3]\n";
# print "True positive: $cm3[0] True negative: $cm3[1] False positive: $cm3[2] False negative: $cm3[3]\n";

sub accuracy {
	my ($tp, $tn, $fp, $fn) = @_;
	return ($tp + $tn) / ($tp + $tn + $fp + $fn); 
}

sub mathews{
	my ($tp, $tn, $fp, $fn) = @_;
	return (($tp * $tn ) - ($fp * fn)) / sqrt(($tp + $fp) * ($tp + $fn) * ($tn + $fp) * ($tn + $fn));
}


$acc1 = accuracy($cm1[0], $cm1[1], $cm1[2], $cm1[3]);
$acc2 = accuracy($cm2[0], $cm2[1], $cm2[2], $cm2[3]);
$acc3 = accuracy($cm3[0], $cm3[1], $cm3[2], $cm3[3]);

$mat1 = mathews($cm1[0], $cm1[1], $cm1[2], $cm1[3]);
$mat2 = mathews($cm2[0], $cm2[1], $cm2[2], $cm2[3]);
$mat3 = mathews($cm3[0], $cm3[1], $cm3[2], $cm3[3]);


print "Prediction accuracy for k = $k1: $acc1 \n";
print "Prediction accuracy for k = $k2: $acc2 \n";
print "Prediction accuracy for k = $k3: $acc3 \n";

print "\n";

print "Mathews correlation coefficient for k = $k1: $mat1 \n";
print "Mathews correlation coefficient for k = $k2: $mat2 \n";
print "Mathews correlation coefficient for k = $k3: $mat3 \n";