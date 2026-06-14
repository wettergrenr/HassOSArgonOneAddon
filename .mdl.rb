# MD013 checks the maximum line length in Markdown files.
# The original 80-character limit is too strict for this repository because
# the documentation contains links, image references and Home Assistant
# installation/configuration text that would become less readable if wrapped
# too aggressively.
#
# Keep the rule enabled, but allow up to 240 characters per line.
rule 'MD013', :line_length => 240
