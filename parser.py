f = open('data/auth.dat')
toks = f.read().split()

nums = []

for t in toks:
    try:
        nums.append(int(t))
    except:
        1

print(nums)

f.close()
f = open('data/formatted_auth.dat', 'w')

for i in range(0, len(nums), 5):
    f.write(str(nums[i:i+5])[1:-1])
    f.write("\n")

f.close()
