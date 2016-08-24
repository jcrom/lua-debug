'use babel';

import LuaDebugView from './lua-debug-view';
import { CompositeDisposable } from 'atom';

export default {

  luaDebugView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.luaDebugView = new LuaDebugView(state.luaDebugViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.luaDebugView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'lua-debug:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.luaDebugView.destroy();
  },

  serialize() {
    return {
      luaDebugViewState: this.luaDebugView.serialize()
    };
  },

  toggle() {
    console.log('LuaDebug was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
