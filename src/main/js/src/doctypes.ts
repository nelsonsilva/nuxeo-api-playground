/**
@license
(C) Copyright Nuxeo Corp. (http://nuxeo.com/)
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Document type.
/// A document type is defined by several [Schema]s and [Facet]s.
class Doctype {

  name: string;
  parent: string;
  facets: string;
  schemas: string;

  constructor(name: string, parent: string, facets: string, schemas: string) {
    this.name = name;
    if (parent !== "None!!!") {
      this.parent = parent;
    }
    this.facets = facets;
    this.schemas = schemas;
  }
}

/// A field in a [Schema].
class SchemaField {
  name: string;
  type: string|Schema;
  isComplex: boolean = false;

  constructor(name: string, type: any) {
    this.name = name;
    if (typeof type == 'string') {
      this.type = type as string;
    } else {
      this.type = Schema.fromJSON(type);
      this.isComplex = true;
    }
  }
}

/// A schema represents the names and structure (types) of a set of fields in a document.
class Schema {
  name: string;
  prefix: string;
  fields: SchemaField[] = [];

  constructor(name, prefix) {
    this.name = name;
    this.prefix = prefix;
  }

  static fromJSON(json): Schema {
    var schema = new Schema(json.name, json["@prefix"]);
    Object.entries(json.fields).forEach(([k, v]) => { schema.fields.push(new SchemaField(k, v)); });
    return schema;
  }
}

/// A facet describes an aspect of a document that can apply to several document types or document instances.
/// Facets can have zero, one or more [Schema]s associated to them.
class Facet {
  name: string;
  schemas: string[] = [];

  constructor(name: string) {
    this.name = name;
  }

  static fromJSON(json): Facet {
    var facet = new Facet(json.name);
    if (json.schemas != null) {
      facet.schemas = json.schemas.map((s) => s.name);
    }
    return facet;
  }
}

async function fetchTypes(client: Nuxeo) {
    
  let _fetch = (path): Promise<any> => client.request(`/config/${path}`).get();

  return {
    types: await _fetch('types').then((l) => Object.entries(l.doctypes).map(([k, v]) => new Doctype(
      k,
      v['parent'],
      v['schemas'],
      v['facets'])
    )),
    schemas: await _fetch('schemas').then((l) => l.map(Schema.fromJSON)),
    facets: await _fetch('facets').then((l) => l.map(Facet.fromJSON))
  };
}

export { Doctype, Schema, Facet, fetchTypes };