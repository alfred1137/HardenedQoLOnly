Hardened.Hooks.XBBCODE_process = XBBCODE.process;
XBBCODE.process = function(config)
{
	// QoL: improve formatting of minus signs in colored text
	// Replace hyphen-minus after [color=...] with en dash surrounded by non-breaking spaces
	config.text = config.text.replace(/(\[color=[^\]]+\])-/g, "$1&nbsp;–&nbsp;");

	var ret = Hardened.Hooks.XBBCODE_process(config);

	ret.html = ret.html.replace(
		/(?:\[|&#91;)wbr(?:\]|&#93;)(?:\[|&#91;)\/wbr(?:\]|&#93;)/g,
		"<wbr>"
	);

	return ret;
};
