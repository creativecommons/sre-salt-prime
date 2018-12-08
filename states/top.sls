base:
 '*':
   - common
   - user
 'roles:salt-prime':
   - match: pillar
   - salt.prime
