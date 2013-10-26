/*
 * Custom JSHint reporter for Vim plugin
 * <https://github.com/Shutnik/jshint2.vim>
 *
 * Author: Nikolay S. Frantsev
 * <http://frantsev.ru/>
 *
 * License: GNU GPL 3
 * <http://www.gnu.org/licenses/gpl.html>
 */

/*jshint node:true*/

'use strict';

exports.reporter = function (reports) {
	var index = -1, length = reports.length,
		error, line,
		result = '',
		code;

	while (++index < length) {
		if ((line = (error = reports[index].error).line) > 1) { // filter command line flags errors
			result +=
				(line - 2) + '\t' + // quickfix lines starts with 1 + 1 line for command line flags
				error.character + '\t' +
				error.reason + '\t' +
				((typeof (code = error.code) === 'string') ? // see https://github.com/jshint/jshint/pull/1164
					code.charAt(0) + '\t' +
						code.substring(1) : '\t') +
				'\n';
		}
	}

	process.stdout.write(result);

	process.exit(0); // prevent showing shell error
};
