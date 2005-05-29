package Text::Highlight::HTML;
use strict;

#TODO:
# 1) DONE - Convert some tag list into a hashref syntax tree for sub syntax
# 2) More distant goal: rewrite this not using HTML::SyntaxHighlighter
#    as I'm not much of a fan of its highlighting method. I'd prefer
#    html tags one color, attrib names another, and attrib vals as 
#    strings. This wouldn't highlight the </> around the tags. Maybe 
#    this is just how whatever text editors I've used have done it, 
#    but it feels more "right".
#
#    At the very least, I'd keep an option for using it as-is. This
#    means creating some kind of optional "options" hashref that gets
#    passed to individual T::H::foo methods. Maybe have one all should
#    implement that uses the method builtin to T::H itself. Got some
#    other shit to iron out first.
# 3) Looks like this method is html-escaping all text, which may not 
#    be the desired escape method. Something else to look into when 
#    poking here again.

#array of types, allows for span tag nesting
my @types = (undef);

#HTML::SyntaxHighlighter to Text::Highlight class translations
my %classes = (
	'D' => 'key4',   #DTD
	'H' => 'key3',   #html/head/body
	'B' => 'key1',   #block
	'I' => 'key2',   #inline
	'A' => 'string', #attribute values
	'T' =>  undef,   #text
	'S' => 'key5',   #script/style
	'C' => 'comment',
);

sub highlight
{
	shift; #class method's class name
	my $obj = shift;
	my $code = shift;

	eval {
		require HTML::SyntaxHighlighter; 
		require HTML::Parser;
	};
	if ( $@ ) {
		$obj->{_active} = __PACKAGE__->syntax;
		$obj->_highlight($code);
		return;
	}
	
	my $out;
	my $p = HTML::SyntaxHighlighter->new(br => "", out_func => \$out);
	$p->parse($code);
	
	#HTML::Entity's decode_entities method doesn't seem to convert nbsp's into spaces
	# (and some lazy html omits the semi-colon)
	$out =~ s/&nbsp;?/ /g;

	HTML::Parser->new(
		api_version => 3,
		handlers    => {
			start => [\&start, 'tagname,attr'],
			end   => [\&end,   'tagname'],
			#colorize the decoded text as the type on top of the @types stack
			text => [ sub { $obj->_colorize($types[-1], shift) }, 'dtext'],

		},
	)->parse($out);
}

#if it's a span tag, look up the tag's class for its Highlighter type and push it on the stack
sub start
{
	return if shift ne 'span';
	my $attr = shift;
	push @types, exists $classes{$attr->{class}} ? $classes{$attr->{class}} : undef;
}

#if it's a span tag, pop the top type off the stack
sub end
{
	pop @types if shift eq 'span';
}

sub syntax {
	return {
          'name' => 'HTML',
          'blockCommentOn' => [
                                '<!--'
                              ],
          'case' => 0,
          'key3' => {
                      'ne' => 'ne',
                      'le' => 'le',
                      'para' => 'para',
                      'xi' => 'Xi',
                      'nu' => 'Nu',
                      'darr' => 'dArr',
                      'oacute' => 'Oacute',
                      'omega' => 'Omega',
                      'prime' => 'Prime',
                      'pound' => 'pound',
                      'igrave' => 'Igrave',
                      'thorn' => 'THORN',
                      'forall' => 'forall',
                      'emsp' => 'emsp',
                      'lowast' => 'lowast',
                      'brvbar' => 'brvbar',
                      'alefsym' => 'alefsym',
                      'nbsp' => 'nbsp',
                      'delta' => 'Delta',
                      'clubs' => 'clubs',
                      'quot' => 'quot',
                      'cedil' => 'cedil',
                      'and' => 'and',
                      'plusmn' => 'plusmn',
                      'ge' => 'ge',
                      'uml' => 'uml',
                      'raquo' => 'raquo',
                      'equiv' => 'equiv',
                      'laquo' => 'laquo',
                      'rdquo' => 'rdquo',
                      'divide' => 'divide',
                      'fnof' => 'fnof',
                      'chi' => 'Chi',
                      'iacute' => 'Iacute',
                      'sigma' => 'Sigma',
                      'acute' => 'acute',
                      'frac34' => 'frac34',
                      'upsih' => 'upsih',
                      'lrm' => 'lrm',
                      'part' => 'part',
                      'exist' => 'exist',
                      'nabla' => 'nabla',
                      'image' => 'image',
                      'prop' => 'prop',
                      'omicron' => 'Omicron',
                      'zwj' => 'zwj',
                      'gt' => 'gt',
                      'aacute' => 'Aacute',
                      'bsub' => 'bsub',
                      'weierp' => 'weierp',
                      'rsquo' => 'rsquo',
                      'otimes' => 'otimes',
                      'kappa' => 'Kappa',
                      'thetasym' => 'thetasym',
                      'harr' => 'hArr',
                      'ograve' => 'Ograve',
                      'sdot' => 'sdot',
                      'copy' => 'copy',
                      'oplus' => 'oplus',
                      'acirc' => 'Acirc',
                      'zeta' => 'Zeta',
                      'sup' => 'sup',
                      'crarr' => 'crarr',
                      'lsquo' => 'lsquo',
                      'bdquo' => 'bdquo',
                      'apos' => 'apos',
                      'eacute' => 'Eacute',
                      'egrave' => 'Egrave',
                      'lceil' => 'lceil',
                      'piv' => 'piv',
                      'ldquo' => 'ldquo',
                      'cent' => 'cent',
                      'uarr' => 'uArr',
                      'hellip' => 'hellip',
                      'ensp' => 'ensp',
                      'sect' => 'sect',
                      'aelig' => 'AElig',
                      'curren' => 'curren',
                      'ordf' => 'ordf',
                      'sbquo' => 'sbquo',
                      'macr' => 'macr',
                      'rho' => 'Rho',
                      'sup2' => 'sup2',
                      'euro' => 'euro',
                      'aring' => 'Aring',
                      'mdash' => 'mdash',
                      'otilde' => 'Otilde',
                      'uuml' => 'Uuml',
                      'eta' => 'Eta',
                      'uacute' => 'uacute',
                      'agrave' => 'agrave',
                      'notin' => 'notin',
                      'ndash' => 'ndash',
                      'sube' => 'sube',
                      'szlig' => 'szlig',
                      'micro' => 'micro',
                      'not' => 'not',
                      'sup1' => 'sup1',
                      'middot' => 'middot',
                      'ecirc' => 'Ecirc',
                      'iota' => 'Iota',
                      'lsaquo' => 'lsaquo',
                      'thinsp' => 'thinsp',
                      'sum' => 'sum',
                      'ntilde' => 'Ntilde',
                      'scaron' => 'Scaron',
                      'atilde' => 'Atilde',
                      'cap' => 'cap',
                      'lang' => 'lang',
                      'isin' => 'isin',
                      'gamma' => 'Gamma',
                      'upsilon' => 'Upsilon',
                      'ang' => 'ang',
                      'hearts' => 'hearts',
                      'spades' => 'spades',
                      'dagger' => 'Dagger',
                      'int' => 'int',
                      'rlm' => 'rlm',
                      'infin' => 'infin',
                      'ugrave' => 'Ugrave',
                      'oslash' => 'Oslash',
                      'rsaquo' => 'rsaquo',
                      'alpha' => 'Alpha',
                      'mu' => 'Mu',
                      'ni' => 'ni',
                      'real' => 'real',
                      'bull' => 'bull',
                      'beta' => 'Beta',
                      'icirc' => 'Icirc',
                      'eth' => 'ETH',
                      'prod' => 'prod',
                      'larr' => 'larr',
                      'ordm' => 'ordm',
                      'perp' => 'perp',
                      'reg' => 'reg',
                      'ucirc' => 'Ucirc',
                      'psi' => 'Psi',
                      'tilde' => 'tilde',
                      'zwnj' => 'zwnj',
                      'asymp' => 'asymp',
                      'deg' => 'deg',
                      'times' => 'times',
                      'sim' => 'sim',
                      'circ' => 'circ',
                      'theta' => 'Theta',
                      'sup3' => 'sup3',
                      'tau' => 'Tau',
                      'frac14' => 'frac14',
                      'oelig' => 'OElig',
                      'diams' => 'diams',
                      'shy' => 'shy',
                      'or' => 'or',
                      'phi' => 'Phi',
                      'iuml' => 'Iuml',
                      'rfloor' => 'rfloor',
                      'iexcl' => 'iexcl',
                      'ccedil' => 'Ccedil',
                      'cong' => 'cong',
                      'frac12' => 'frac12',
                      'rarr' => 'rArr',
                      'loz' => 'loz',
                      'cup' => 'cup',
                      'radic' => 'radic',
                      'euml' => 'Euml',
                      'frasl' => 'frasl',
                      'lt' => 'lt',
                      'lamdba' => 'Lamdba',
                      'there4' => 'there4',
                      'ouml' => 'Ouml',
                      'oline' => 'oline',
                      'yacute' => 'Yacute',
                      'amp' => 'amp',
                      'auml' => 'Auml',
                      'sigmaf' => 'sigmaf',
                      'permil' => 'permil',
                      'iquest' => 'iquest',
                      'pi' => 'Pi',
                      'empty' => 'empty',
                      'supe' => 'supe',
                      'yen' => 'yen',
                      'rang' => 'rang',
                      'trade' => 'trade',
                      'minus' => 'minus',
                      'lfloor' => 'lfloor',
                      'sub' => 'sub',
                      'epsilon' => 'Epsilon',
                      'yuml' => 'Yuml',
                      'ocirc' => 'Ocirc'
                    },
          'key2' => {
                      'http-equiv' => 'http-equiv',
                      'content' => 'content',
                      'clear' => 'clear',
                      '#implied' => '#IMPLIED',
                      'target' => 'target',
                      'onkeydown' => 'onkeydown',
                      'onkeyup' => 'onkeyup',
                      'onmouseup' => 'onmouseup',
                      'scope' => 'scope',
                      'onmouseover' => 'onmouseover',
                      'lang' => 'lang',
                      'align' => 'align',
                      'valign' => 'valign',
                      'idref' => 'IDREF',
                      'name' => 'name',
                      'scheme' => 'scheme',
                      'charset' => 'charset',
                      'prompt' => 'prompt',
                      '#pcdata' => '#PCDATA',
                      'frameborder' => 'frameborder',
                      'onmousedown' => 'onmousedown',
                      'rev' => 'rev',
                      'title' => 'title',
                      'span' => 'span',
                      'onclick' => 'onclick',
                      'start' => 'start',
                      'width' => 'width',
                      'vlink' => 'vlink',
                      'usemap' => 'usemap',
                      'nowrap' => 'nowrap',
                      'coords' => 'coords',
                      'frame' => 'frame',
                      'size' => 'size',
                      'onblur' => 'onblur',
                      'dir' => 'dir',
                      'datetime' => 'datetime',
                      'face' => 'face',
                      'color' => 'color',
                      'summary' => 'summary',
                      'html' => 'html',
                      '-//w3c//dtd xhtml 1.0 transitional//en' => '-//W3C//DTD XHTML 1.0 Transitional//EN',
                      'bgcolor' => 'bgcolor',
                      'text' => 'text',
                      'vspace' => 'vspace',
                      'tabindex' => 'tabindex',
                      'standby' => 'standby',
                      'language' => 'language',
                      'style' => 'style',
                      'onmousemove' => 'onmousemove',
                      'background' => 'background',
                      'height' => 'height',
                      '-//w3c//dtd xhtml 1.0 frameset//en' => '-//W3C//DTD XHTML 1.0 Frameset//EN',
                      'codetype' => 'codetype',
                      'char' => 'char',
                      'multiple' => 'multiple',
                      'codebase' => 'codebase',
                      'rel' => 'rel',
                      'profile' => 'profile',
                      'xmlns' => 'xmlns',
                      '#fixed' => '#FIXED',
                      '#required' => '#REQUIRED',
                      'ondblclick' => 'ondblclick',
                      'axis' => 'axis',
                      'marginwidth' => 'marginwidth',
                      'cols' => 'cols',
                      'readonly' => 'readonly',
                      'onchange' => 'onchange',
                      '-//w3c//dtd xhtml 1.0 strict//en' => '-//W3C//DTD XHTML 1.0 Strict//EN',
                      'abbr' => 'abbr',
                      'media' => 'media',
                      'href' => 'href',
                      'id' => 'id',
                      'nmtoken' => 'NMTOKEN',
                      'compact' => 'compact',
                      'value' => 'value',
                      'src' => 'src',
                      'for' => 'for',
                      'data' => 'data',
                      'xml:space' => 'xml:space',
                      'hreflang' => 'hreflang',
                      'checked' => 'checked',
                      'declare' => 'declare',
                      'onkeypress' => 'onkeypress',
                      'http://www.w3.org/tr/xhtml1/dtd/xhtml1-frameset.dtd' => 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd',
                      'type' => 'type',
                      'shape' => 'shape',
                      'label' => 'label',
                      'class' => 'class',
                      'accesskey' => 'accesskey',
                      'http://www.w3.org/tr/xhtml1/dtd/xhtml1-transitional.dtd' => 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd',
                      'object' => 'object',
                      'disabled' => 'disabled',
                      'headers' => 'headers',
                      'scrolling' => 'scrolling',
                      'noresize' => 'noresize',
                      'rules' => 'rules',
                      'rows' => 'rows',
                      'cdata' => 'CDATA',
                      'onfocus' => 'onfocus',
                      'alink' => 'alink',
                      'rowspan' => 'rowspan',
                      'colspan' => 'colspan',
                      'defer' => 'defer',
                      'slign' => 'slign',
                      'cellspacing' => 'cellspacing',
                      'public' => 'PUBLIC',
                      'http://www.w3.org/tr/xhtml1/dtd/xhtml1-strict.dtd' => 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd',
                      'empty' => 'EMPTY',
                      'charoff' => 'charoff',
                      'cite' => 'cite',
                      'marginheight' => 'marginheight',
                      'maxlength' => 'maxlength',
                      'link' => 'link',
                      'onselect' => 'onselect',
                      'archive' => 'archive',
                      'alt' => 'alt',
                      'accept' => 'accept',
                      'longdesc' => 'longdesc',
                      'classid' => 'classid',
                      'onmouseout' => 'onmouseout',
                      'xml:lang' => 'xml:lang',
                      'border' => 'border',
                      'noshade' => 'noshade',
                      'onunload' => 'onunload',
                      'hspace' => 'hspace',
                      'onload' => 'onload',
                      'valuetype' => 'valuetype',
                      'cellpadding' => 'cellpadding',
                      'selected' => 'selected'
                    },
          'lineComment' => [],
          'delimiters' => '<>/%="\',.(){}[]+*~&|;',
          'key1' => {
                      'tr' => 'tr',
                      'strike' => 'strike',
                      'input' => 'input',
                      '!entity' => '!ENTITY',
                      'table' => 'table',
                      'form' => 'form',
                      'h5' => 'h5',
                      'meta' => 'meta',
                      'map' => 'map',
                      'isindex' => 'isindex',
                      'tfoot' => 'tfoot',
                      'caption' => 'caption',
                      'code' => 'code',
                      'base' => 'base',
                      'br' => 'br',
                      'acronym' => 'acronym',
                      'strong' => 'strong',
                      'h4' => 'h4',
                      'em' => 'em',
                      'q' => 'q',
                      'b' => 'b',
                      'title' => 'title',
                      'span' => 'span',
                      'applet' => 'applet',
                      'small' => 'small',
                      'area' => 'area',
                      'frame' => 'frame',
                      'dir' => 'dir',
                      'body' => 'body',
                      'ol' => 'ol',
                      'html' => 'html',
                      'var' => 'var',
                      'ul' => 'ul',
                      '?xml' => '?xml',
                      'del' => 'del',
                      'blockquote' => 'blockquote',
                      'style' => 'style',
                      'iframe' => 'iframe',
                      'dfn' => 'dfn',
                      'h3' => 'h3',
                      'textarea' => 'textarea',
                      'a' => 'a',
                      'img' => 'img',
                      'tt' => 'tt',
                      'font' => 'font',
                      'noframes' => 'noframes',
                      'thead' => 'thead',
                      'u' => 'u',
                      'abbr' => 'abbr',
                      'sup' => 'sup',
                      'h6' => 'h6',
                      'address' => 'address',
                      'param' => 'param',
                      'basefont' => 'basefont',
                      'th' => 'th',
                      'h1' => 'h1',
                      'head' => 'head',
                      'tbody' => 'tbody',
                      'legend' => 'legend',
                      'dd' => 'dd',
                      's' => 's',
                      '!doctype' => '!DOCTYPE',
                      'hr' => 'hr',
                      '!attlist' => '!ATTLIST',
                      'li' => 'li',
                      'td' => 'td',
                      'label' => 'label',
                      'dl' => 'dl',
                      'kbd' => 'kbd',
                      'object' => 'object',
                      'div' => 'div',
                      'dt' => 'dt',
                      'pre' => 'pre',
                      'center' => 'center',
                      '!element' => '!ELEMENT',
                      'samp' => 'samp',
                      'col' => 'col',
                      'option' => 'option',
                      'cite' => 'cite',
                      'select' => 'select',
                      'i' => 'i',
                      'link' => 'link',
                      'script' => 'script',
                      'bdo' => 'bdo',
                      'menu' => 'menu',
                      'colgroup' => 'colgroup',
                      'h2' => 'h2',
                      'ins' => 'ins',
                      'p' => 'p',
                      'sub' => 'sub',
                      'big' => 'big',
                      'fieldset' => 'fieldset',
                      'frameset' => 'frameset',
                      'button' => 'button',
                      'noscript' => 'noscript',
                      'optgroup' => 'optgroup'
                    },
          'quot' => [
                      '\'',
                      '"'
                    ],
          'blockCommentOff' => [
                                 '-->'
                               ],
          'escape' => '\\',
          'continueQuote' => 0
        };
}

1;
__END__
