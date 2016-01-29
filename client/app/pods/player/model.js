import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  last_name_change: DS.attr('date'),
  password: DS.attr('string'),
  email: DS.attr('string'),
  email_verified: DS.attr('boolean'),
  last_login: DS.attr('date'),
  failed_login_attempts: DS.attr('integer'),
  login_lock: DS.attr('string')
});