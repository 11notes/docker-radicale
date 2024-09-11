from string import hexdigits

STATE_ANY = 0
STATE_ESCAPE = 1
STATE_ESCAPE_HEX = 2


def value(attribute_value):
    if not attribute_value:
        return ''

    if attribute_value[0] == '#':  # with leading SHARP only pairs of hex characters are valid
        valid_hex = True
        if len(attribute_value) % 2 == 0:  # string must be # + HEX HEX (an odd number of chars)
            valid_hex = False

        if valid_hex:
            for c in attribute_value:
                if c not in hexdigits:  # allowed only hex digits as per RFC 4514
                    valid_hex = False
                    break

        if valid_hex:
            return attribute_value

    state = STATE_ANY
    escaped = ''
    tmp_buffer = ''
    for c in attribute_value:
        if state == STATE_ANY:
            if c == '\\':
                state = STATE_ESCAPE
            elif c in '"#+,;<=>\00':
                escaped += '\\' + c
            else:
                escaped += c
        elif state == STATE_ESCAPE:
            if c in hexdigits:
                tmp_buffer = c
                state = STATE_ESCAPE_HEX
            elif c in ' "#+,;<=>\\\00':
                escaped += '\\' + c
                state = STATE_ANY
            else:
                escaped += '\\\\' + c
        elif state == STATE_ESCAPE_HEX:
            if c in hexdigits:
                escaped += '\\' + tmp_buffer + c
            else:
                escaped += '\\\\' + tmp_buffer + c
            tmp_buffer = ''
            state = STATE_ANY

    # final state
    if state == STATE_ESCAPE:
        escaped += '\\\\'
    elif state == STATE_ESCAPE_HEX:
        escaped += '\\\\' + tmp_buffer

    if escaped[0] == ' ':  # leading SPACE must be escaped
        escaped = '\\' + escaped

    if escaped[-1] == ' ' and len(escaped) > 1 and escaped[-2] != '\\':  # trailing SPACE must be escaped
        escaped = escaped[:-1] + '\\ '

    return escaped
