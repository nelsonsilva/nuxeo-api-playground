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

/// The API Object describes one or more operations on a single path.
interface Resource {
  path: string;
  description: string;
  operations: Operation[];
}

/// The Operation object describes a single operation on a path.
interface Operation {
  method: string;
  name: string;
  type: string;
  summary: string;
  notes: string;
  parameters: Parameter[];
}

/// The Parameter Object describes a single parameter to be sent in an operation.
interface Parameter {
  name: string;
  paramType: string;
  description: string;
  dataType: string;
  required: string;
}

export { Resource, Operation, Parameter}
