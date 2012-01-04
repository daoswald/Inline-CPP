use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME => 'Inline::CPP::grammar',
	      VERSION_FROM => 'grammar.pm',
	      PREREQ_PM => { 'Parse::RecDescent' => 0 },
	     );
