/**
 * Class decorator that registers a custom element class.
 */
export const customElement = (tagName: string) => (clazz: any) => {
  window.customElements.define(tagName, clazz);
  return clazz;
};