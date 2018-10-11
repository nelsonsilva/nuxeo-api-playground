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
import { Doctype, Schema, Facet } from './doctypes';

enum DiagramStyle {
  BORING = "nofunky",
  PLAIN = "plain"
}

const STYLE = DiagramStyle.BORING;
const SCALE = 80;
const DIRECTION = "TB";
const KIND = "class";
const URL = `http://yuml.me/diagram/${STYLE};scale:${SCALE};dir:${DIRECTION};/${KIND}/`;

/// A diagram generator for [DocType]s, [Facet]s and [Schema]s using [yUML](http://yuml.me)
export class DiagramGenerator {

  doctypes = new Map<string, Doctype>();
  schemas = new Map<string, Schema>();
  facets = new Map<string, Facet>();

  constructor(
    doctypes: Doctype[],
    schemas: Schema[],
    facets: Facet[]) {
    doctypes.forEach((d) => this.doctypes[d.name] = d);
    schemas.forEach((s) => this.schemas[s.name] = s);
    facets.forEach((f) => this.facets[f.name] = f);
  }

  /// Returns a URL for a diagram for the given [Doctype].
  generateForDoctype(name: string) { return URL + this._umlForDoctype(name).join(","); }
  /// Returns a URL for a diagram for the given [Facet].
  generateForFacet(name: string) { return URL + this._umlForFacet(name).join(","); }
  /// Returns a URL for a diagram for the given [Schema].
  generateForSchema(name: string) { return URL + this._umlForSchema(name).join(","); }

  _umlForDoctype(name: string): string[] {
    let doctype = this.doctypes[name];

    let uml = [`[${doctype.name}]`];

    let inheritedFacets = [],
        inheritedSchemas = [];

    // Inheritance
    // [Parent]^-[Child]
    if (doctype.parent != null) {
      uml.push(`[${doctype.parent}]^-[${doctype.name}]`);
      uml = uml.concat(this._umlForDoctype(doctype.parent));

      // Get the list of inherited facets and schemas
      inheritedFacets = this.doctypes[doctype.parent].facets;
      inheritedSchemas = this.doctypes[doctype.parent].schemas;
    }

    // Facets
    // [Doctype]-.->[Facet]
    doctype.facets
    .filter((f) => !inheritedFacets.includes(f))
    .forEach((f) => {
      uml.push(`[${doctype.name}]-.->[<<${f}>>]`);
      uml = uml.concat(this._umlForFacet(f));
    });

    var facetSchemas = [];
    
    doctype.facets.forEach(f => facetSchemas = facetSchemas.concat(this.facets[f].schemas));

    // Schemas
    // [Doctype or Facet]++->[Schema]
    doctype.schemas
    .where((s) => !inheritedSchemas.includes(s) && !facetSchemas.includes(s))
    .forEach((s) => {
      var schema = this.schemas[s];
      uml.push(`[${doctype.name}]++->[${schema.prefix}:${schema.name}]`);
      uml = uml.concat(this._umlForSchema(s));
    });

    return uml;
  }

  _umlForFacet(name: string): string[] {
    var facet = this.facets[name];
    var uml = [`[<<${facet.name}>>]`];
    // Schemas
    // [Doctype or Facet]++->[Schema]
    facet.schemas
    .forEach((s) => {
      var schema = this.schemas[s];
      uml.push(`[<<${facet.name}>>]++->[${schema.prefix}:${schema.name}]`);
      uml = uml.concat(this._umlForSchema(s));
    });
    return uml;
  }

  _umlForSchema(name: string): string[] {
    var schema = this.schemas[name];
    var fields = schema.fields.map((f) => f.name).join(";");
    return [`[${schema.prefix}:${schema.name}|$fields]`];
  }
}