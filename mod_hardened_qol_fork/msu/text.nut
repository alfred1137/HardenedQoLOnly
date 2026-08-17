::MSU.Text.Color.HD_Blue <- "#1e468f";

::MSU.Text.colorNeutral <- function( _string )
{
	return this.color(::MSU.Text.Color.HD_Blue, _string);
}

// QoL: improve formatting of minus signs in front of negative numbers
// Vanilla uses hyphen-minus which is half as wide as plus sign and lacks built-in spacing
// Replace with en dash (U+2013) surrounded by non-breaking spaces for readability
// note: JS-side hook in xbbcode.js handles HTML tooltips; this hook covers tactical tooltips
local oldColor = ::MSU.Text.color;
::MSU.Text.color = function( _color, _string )
{
	_string = _string.tostring();
	if (_string.find("-") == 0)
	{
		_string = "&nbsp–&nbsp" + _string.slice(1);
	}

	return oldColor(_color, _string);
}
