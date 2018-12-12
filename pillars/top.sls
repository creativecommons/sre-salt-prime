{{ saltenv }}:
  '*':
    - salt
    - user
    - user.passwords.*
  '*__*__us-east-2':
    - aws
    - aws.us-east-2
  '*__core__us-east-2':
    - aws.us-east-2.core
  '*__gnwp__us-east-2':
    - aws.us-east-2.gnwp
