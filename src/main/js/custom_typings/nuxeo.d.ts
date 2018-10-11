interface User {
  id: string;
}

interface Operation {

}

interface BaseOptions {
  repositoryName: string;
  schemas: string[];
  enrichers: string;
  fetchProperties: any;
  translateProperties: string;
  depth: number;
  headers: string;
  timeout: number;
  transactionTimeout: number;
  httpTimeout: number;
}

interface Base {
  _baseOptions: BaseOptions;
  enrichers(enrichers, override?: boolean);

  _computeOptions(opts?);
}

interface Request extends Base {
  _path: string;
  _queryParams: any;
  _url: string;

  get();
  queryParams(params);
  execute(opts?)
}

interface Document {
  uid: string;
  path: string;
}

interface Repository {
  fetch(ref:string, opts?): Promise<Document>;
  query(opts): Promise<any>;
}

declare class Nuxeo {
  _baseURL: string;
  _restURL: string;
  _automationUrl: string;
  connected: boolean;
  user: User;
  constructor(options: any);
  connect(opts?): Nuxeo;
  http(opts?);
  request(path: string): Request;
  operation(id: string, opts?): Operation;
  repository(name?: string, opts?): Repository
  batchUpload(opts?);

  _computeFetchOptions(opts?);
}