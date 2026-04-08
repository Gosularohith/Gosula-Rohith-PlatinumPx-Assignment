# Python Solutions

# 1) Convert minutes to human readable format
def convert_minutes(minutes):
    hrs = minutes // 60
    mins = minutes % 60

    if hrs > 0:
        return f"{hrs} hr{'s' if hrs > 1 else ''} {mins} minutes"
    else:
        return f"{mins} minutes"

print(convert_minutes(130))
print(convert_minutes(110))


# 2) Remove duplicates from string using loop
def remove_duplicates(s):
    result = ""
    for char in s:
        if char not in result:
            result += char
    return result

print(remove_duplicates("programming"))
