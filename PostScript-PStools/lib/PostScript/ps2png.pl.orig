#!/usr/bin/perl
#
# ps2png.pl     Norbert Haider, University of Vienna, 2005
#
# Script reads a Postscript file (obtained from a MDL molfile
# with the utility program mol2ps) and generates a 2D
# graphical images in PNG format by piping the PS file through 
# Ghostscript.
#
# Ghostscript must be installed and the "gs" command must be in
# your search path.


# =============== user customizable parameters: ===============

$scalingfactor = 0.22;    # 0.22 gives good results

# =============================================================

if ($#ARGV < 0) {
  print "Usage: ps2png.pl <inputfile>\n";
  exit;
}

$infile = $ARGV[0];

$outfile = $infile;
if (index($outfile,'.') > -1) {
  $outfile = substr($outfile,0,rindex($outfile,'.'));
}
$outfile = $outfile . '.png';

$molps = "";

open (PSFILE, "<$infile") || die ("cannot open input file $infile!");

while ($line = <PSFILE>) {
  $line =~ s/\r//g;      # remove carriage return characters (DOS/Win)
  $molps = $molps . $line;
}


$bb =  filterthroughcmd($molps,"gs -q -sDEVICE=bbox -dNOPAUSE -dBATCH  -r300 -g500000x500000 - ");
@bbrec =   split(/\n/, $bb);
$bblores = $bbrec[0];
$bblores =~ s/%%BoundingBox://g;
chomp($bblores);
$bblores = ltrim($bblores);
@bbcorner = split(/\ /, $bblores);
$bbleft = $bbcorner[0];
$bbbottom = $bbcorner[1];
$bbright = $bbcorner[2];
$bbtop = $bbcorner[3];
$sf = $scalingfactor;
$xtotal = ($bbright + $bbleft) * $sf;
$ytotal = ($bbtop + $bbbottom) * $sf;
if (($xtotal > 0) && ($ytotal > 0)) {
  $molps = $sf . " " . $sf . " scale\n" . $molps;  ## insert the PS "scale" command
  #print "low res: $bblores  .... max X: $bbright, max Y: $bbtop \n";
  print "writing file $outfile with output dimensions of $xtotal x $ytotal pt\n";
} else {
  $xtotal = 99;
  $ytotal = 55;
  $molps = "%!PS-Adobe
  /Helvetica findfont 14 scalefont setfont
  10 30 moveto
  (2D structure) show
  10 15 moveto
  (not available) show
  showpage\n";
  print "writing empty file\n";
}	
$gsopt1 = " -r300 -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -dEVICEWIDTHPOINTS=";
$gsopt1 = $gsopt1 . $xtotal . " -dDEVICEHEIGHTPOINTS=" . $ytotal;
$gsopt1 = $gsopt1 . " -sOutputFile=" . $outfile;
$gscmd = "gs -q -sDEVICE=pnggray -dNOPAUSE -dBATCH " . $gsopt1 . " - ";
system("echo \"$molps\" \| $gscmd");


# =============================================================

sub filterthroughcmd {
  $input   = shift;
  $cmd     = shift;
  open(FHSUB, "echo \"$input\"|$cmd 2>&1 |");   # stderr must be redirected to stdout
  $res      = "";                               # because the Ghostscript "bbox" device
  while($line = <FHSUB>) {                      # writes to stderr
    $res = $res . $line;
  }
  return $res;
}

sub ltrim() {
  $subline1 = shift;
  $subline1 =~ s/^\ +//g;
  return $subline1;
}

