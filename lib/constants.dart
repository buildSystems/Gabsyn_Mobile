
class Constants{
  static final BASE_ROUTE = 'http://10.0.2.2:3001/api/';
  static final SITE_ROUTE = 'http://10.0.2.2:3001';
 // static final BASE_ROUTE = 'http://161.35.175.18/api/';
 // static final SITE_ROUTE = 'http://161.35.175.18';
  static final Routes = {
    'LOGIN': BASE_ROUTE + 'auth/login',
    'CREATE_USER_AND_LOAN': BASE_ROUTE + 'staff/create-and-apply',
    'FETCH_COLLECTION_MATCHES': BASE_ROUTE + "collections/search",
    'REGISTER_COLLECTION': BASE_ROUTE + 'collections/save',
    'FETCH_STATES': BASE_ROUTE + "states",
  };
}